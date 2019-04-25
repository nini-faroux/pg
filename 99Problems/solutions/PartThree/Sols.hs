module PartThree.Sols where 

import System.Random (randomRIO)

-- 21 
-- insertAt 'X' "abcd" 2
-- "aXbcd"
insertAt :: a -> [a] -> Int -> [a] 
insertAt x xs k = take (k-1) xs ++ [x] ++ drop (k-1) xs

-- 22
-- > range 4 9
-- [4,5,6,7,8,9]
range :: Int -> Int -> [Int] 
range s e = [s..e]

-- 23
-- Extract a given number of randomly selected elements from a list.
-- λ> rnd_select "abcdefgh" 3 >>= putStrLn
-- eda
rndSelect :: [a] -> Int -> IO [a] 
rndSelect xs n = go xs 0 [] (randomRIO (0, length xs-1)) 
  where 
    go xs cnt acc rg
      | cnt == n = return acc 
      | otherwise = do 
           rnd <- rg 
           go xs (cnt+1) (acc ++ [xs !! rnd]) rg
