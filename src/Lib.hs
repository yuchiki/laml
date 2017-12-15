
module Lib
    ( someFunc
    ) where

import Text.Parsec
import Text.Parsec.String

someFunc :: IO ()
someFunc = putStrLn "someFunc"


type Content = [Block]
data Block = Block Sentence Content deriving(Show)
data Sentence = HeaderSentence Header | NormalSentence String deriving(Show)
data Header = Header HeaderType Name (Maybe OptionalArg) (Maybe FirstArg) deriving (Show)
data HeaderType = Section | Environment deriving(Show)
type Name = String
type OptionalArg = String
type FirstArg = String


parseSentence :: Parser Sentence
parseSentence =
    (do
        headerType <- parseHeaderType
        HeaderSentence <$> parseHeader headerType
    ) <|> NormalSentence <$> many (noneOf "")

parseHeader :: HeaderType -> Parser Header
parseHeader headerType = do
    name <- many1 letter <* spaces
    opt <- optionMaybe (between (char optParL) (char optParR) (many (noneOf [optParR])))
    rawArg <- many (noneOf "")
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
--content::= empty | block content
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