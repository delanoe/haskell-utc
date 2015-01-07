module Data.Tempus.Rfc3339.Parser
  ( rfc3339Parser
  ) where

import Control.Monad

import Data.Attoparsec.ByteString ( Parser, skipWhile, choice, option, satisfy )
import Data.Attoparsec.ByteString.Char8 ( char, isDigit_w8 )

import Data.Tempus.GregorianCalendar

rfc3339Parser :: (MonadPlus m, GregorianCalendar t, LocalOffset t) => Parser (m t)
rfc3339Parser 
  = do year    <- dateFullYear
       _       <- char '-'
       month   <- dateMonth
       _       <- char '-'
       day     <- dateMDay
       _       <- char 'T'
       hour    <- timeHour
       _       <- char ':'
       minute  <- timeMinute
       _       <- char ':'
       second  <- timeSecond
       msecond <- option 0 timeSecfrac
       offset  <- timeOffset
       return $ setYear                year commonEpoch
            >>= setMonth               month
            >>= setDay                 day
            >>= setHour                hour
            >>= setMinute              minute
            >>= setSecond              second
            >>= setMilliSecond         msecond
            >>= setLocalOffset         offset
  where
    dateFullYear
      = decimal4
    dateMonth
      = decimal2
    dateMDay
      = decimal2
    timeHour
      = decimal2
    timeMinute
      = decimal2
    timeSecond
      = decimal2
    timeSecfrac
      = do _ <- char '.'
           choice
             [ do d <- decimal3
                  skipWhile isDigit_w8
                  return d
             , do d <- decimal2
                  return (d * 10)
             , do d <- decimal1
                  return (d * 100)
             ]
    timeOffset
      = choice
          [ do _  <- char 'Z'
               return $ Just 0
          , do _  <- char '+'
               x1 <- decimal2
               _  <- char ':'
               x2 <- decimal2
               return $ Just
                      $ x1 * 60
                      + x2
          , do _  <- char '-'
               _  <- char '0'
               _  <- char '0'
               _  <- char ':'
               _  <- char '0'
               _  <- char '0'
               return Nothing
          , do _  <- char '-'
               x1 <- decimal2
               _  <- char ':'
               x2 <- decimal2
               return $ Just
                      $ negate
                      $ x1 * 360000
                      + x2 * 60000
          ]

    decimal1
      = do w8 <- satisfy isDigit_w8
           return (fromIntegral (w8 - 48))
    decimal2
      = do d1 <- decimal1
           d2 <- decimal1
           return $ d1 * 10
                  + d2
    decimal3
      = do d1 <- decimal1
           d2 <- decimal1
           d3 <- decimal1
           return $ d1 * 100
                  + d2 * 10
                  + d3
    decimal4
      = do d1 <- decimal1
           d2 <- decimal1
           d3 <- decimal1
           d4 <- decimal1
           return $ d1 * 1000
                  + d2 * 100
                  + d3 * 10
                  + d4