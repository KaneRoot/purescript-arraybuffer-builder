module Test.Main where

import Prelude (Unit, bind, pure, discard, map, negate, ($), (<$>), (=<<), (<>))
import Data.ArrayBuffer.Types (ArrayBuffer,Uint8Array)
import Data.ArrayBuffer.Typed as AT
import Data.UInt as UInt
import Effect (Effect)
import Test.Assert (assertEqual')
import Data.ArrayBuffer.Builder

asBytes :: ArrayBuffer -> Effect (Array Int)
asBytes x = do
  x' :: Uint8Array <- AT.whole x
  map UInt.toInt <$> AT.toArray x'

putTest :: String -> Array Int -> PutM Effect Unit -> Effect Unit
putTest label expected put = do
  actual <- asBytes =<< execPut put
  assertEqual' label {actual,expected}

buildTest :: String -> Array Int -> Effect Builder -> Effect Unit
buildTest label expected bldr = do
  actual <- asBytes =<< execBuilder =<< bldr
  assertEqual' label {actual,expected}

main :: Effect Unit
main = do
  putTest "Test 0" [6,7,8] $ do
    putInt8 6
    putInt8 7
    putInt8 8

  putTest "Test 1" [255,254] $ do
    putInt16be (-2)

  putTest "Test 3" [3,0,0,0] $ do
    putInt32le 3

  buildTest "Test 4" [1,2,3,4] $ do
    b1 <- encodeInt8 1
    b2 <- encodeInt8 2
    b3 <- encodeInt8 3
    b4 <- encodeInt8 4
    pure $ singleton b1 <> singleton b2 <> singleton b3 <> singleton b4

  buildTest "Test 5" [1,2,3,4] $ do
    b1 <- encodeInt8 1
    b2 <- encodeInt8 2
    b3 <- encodeInt8 3
    b4 <- encodeInt8 4
    pure $ singleton b1 <>> singleton b2 <>> singleton b3 <>> singleton b4

  buildTest "Test 6" [1,2,3,4] $ do
    b1 <- encodeInt8 1
    b2 <- encodeInt8 2
    b3 <- encodeInt8 3
    b4 <- encodeInt8 4
    pure $ singleton b1 <> (singleton b2 <> singleton b3) <> singleton b4
