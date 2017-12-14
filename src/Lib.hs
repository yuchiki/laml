module Lib
    ( someFunc
    ) where

import Text.Parsec
import Text.Parsec.String

someFunc :: IO ()
someFunc = putStrLn "someFunc"


type Content = [Block]
data Block = Block Sentence Content
data Sentence = HeaderSentence Header | NormalSentence String
data Header = Header HeaderType Name (Maybe OptionalArg) (Maybe FirstArg)
data HeaderType = Section | Environment
type Name = String
type OptionalArg = String
type FirstArg = String


contentsP :: Parser Content
contentsP = many blockP

blockP :: Parser Block
blockP = do
    sentence <- sentenceP 
    content <- O
    
sentenceP :: Parser Sentence

headerP :: Parser Header

headerTypeP :: Parser HeaderType
--content::= empty | block content
--block::= sentence
--            (content)
--sentence::= header | normal_sentence
--header::= type (ident) ([option])(arg)
