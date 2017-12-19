module Main where

import Content

main :: IO ()
main = print =<< parseContent <$> getContents
