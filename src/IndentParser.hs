{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}

module IndentParser where
import Data.Char
import Data.List

data MultiTree a = Node a [MultiTree a]
instance (Show a) => Show (MultiTree a) where
    show (Node v trees) = show v ++ "\n" ++ indent indentWidth (show trees)
instance {-# OVERLAPPING #-} Show (MultiTree String) where
    show (Node str trees) = str ++ "\n" ++ indent indentWidth (show trees)

type IndentedString = [MultiTree String]
instance {-# OVERLAPPING #-} Show IndentedString where
    show = concatMap show

type Lines = [String]

indentParse :: String -> IndentedString
indentParse = fst . indentParse' 0 [] . lines

indentParse' :: Int -> IndentedString -> Lines -> (IndentedString, Lines)
indentParse' _ acm [] = (reverse acm, [])
indentParse' amount acm lAll@(rawL:ls)
    | isEmptyLine l = indentParse' amount ( Node "" [] : acm) ls
    | countIndent rawL == amount = indentParse' amount (Node l [] : acm) ls
    | countIndent rawL > amount =
        let (result, ls') = indentParse' (succ amount) [] lAll
        in let (Node acmhead [] : acmtail) = acm
        in indentParse' amount (Node acmhead result : acmtail) ls'
    | countIndent l < amount = (reverse acm, lAll)
        where l = trimIndent rawL


countIndent :: String -> Int
countIndent = flip div indentWidth . length . takeWhile isSpace

trimIndent :: String -> String
trimIndent = dropWhile isSpace

isEmptyLine :: String -> Bool
isEmptyLine = all isSpace 

indentWidth :: Int
indentWidth = 4

indent :: Int -> String -> String
indent amount = unlines . map (replicate amount ' ' ++) . lines