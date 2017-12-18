{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}

module Lib
    ( someFunc, parseContent
    ) where

import Text.Parsec
import Text.Parsec.String
import IndentParser

someFunc :: IO ()
someFunc = putStrLn "someFunc"


type Content = [Block]
data Block = Block Sentence Content
data Sentence = HeaderSentence Header | NormalSentence String
data Header = Header HeaderType Name (Maybe OptionalArg) (Maybe FirstArg) deriving (Show)
data HeaderType = Section | Environment deriving(Show)
type Name = String
type OptionalArg = String
type FirstArg = String

instance {-# Overlapping #-} Show Content where
    show = concatMap show
instance Show Block where
    show (Block (HeaderSentence header) content) =
        concat [headerStr, indent indentWidth (show content), footerStr]
        where (headerStr, footerStr) = createHeaderFooter header
    show (Block sentence content) = concat [show sentence, "\n", indent indentWidth (show content)]
instance Show Sentence where
    show (HeaderSentence header) = show header
    show (NormalSentence str) = str

createHeaderFooter :: Header -> (String, String)
createHeaderFooter (Header headerType name optionalArg firstArg) =
    headerFooterPair headerType
    where
        optionStr = case optionalArg of
            Nothing -> ""
            Just arg -> concat [[optParL], arg, [optParR]]
        argStr = case firstArg of
            Nothing -> ""
            Just arg -> concat ["{", arg ,"}"]
        headerFooterPair Section = (concat ["\\", name, optionStr, argStr, "\n"], "")
        headerFooterPair Environment = (concat ["\\begin{", name, "}", optionStr, argStr, "\n"], concat ["\\end{", name, "}", "\n"])

parseContent :: String -> Content
parseContent = parseContent' . indentParse

parseContent' :: IndentedString -> Content
parseContent' = map parseContent''

parseContent'' :: MultiTree String -> Block
parseContent'' (Node l children) = Block sentence contents
    where
        sentence = takeRight $ parse parseSentence "" l
        contents = parseContent' children

parseSentence :: Parser Sentence
parseSentence =
    (do
        headerType <- parseHeaderType
        HeaderSentence <$> parseHeader headerType
    ) <|> NormalSentence <$> many (noneOf "")


parseHeader :: HeaderType -> Parser Header
parseHeader headerType = do
    name <- many1 letter <* spaces
    opt <- optionMaybe (between (char optParL) (char optParR) (spaces *> many (noneOf [optParR])))
    rawArg <- spaces *> many (noneOf "")
    let arg = case rawArg of 
                "" -> Nothing
                _  -> Just rawArg
    return $ Header headerType name opt arg

parseHeaderType :: Parser HeaderType
parseHeaderType =
    (do
        char sectionSymbol
        return Section
    )<|>(do
        char envSymbol
        return Environment
    )
--content::= empty | block content{-  -}
--block::= sentence
--            (content)
--sentence::= header | normal_sentence
--header::= type (ident) ([option])(arg)

envSymbol :: Char
envSymbol = '.'

sectionSymbol :: Char
sectionSymbol = '%'

optParL :: Char
optParL = '['
optParR :: Char
optParR = ']'

takeRight :: Either a b -> b
takeRight (Right r) = r