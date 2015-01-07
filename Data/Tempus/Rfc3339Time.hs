module Data.Tempus.Rfc3339Time
  ( -- * Type
    Rfc3339Time()
  -- * Creation
  ) where

import Data.String
import Data.Maybe

import Data.Tempus.GregorianCalendar
import Data.Tempus.Rfc3339Time.Type
import Data.Tempus.Rfc3339

instance Show Rfc3339Time where
  -- The assumption is that every Rfc3339Time is valid and renderable as Rfc3339 string
  -- and rendering failure is impossible.
  show = fromMaybe "0000-00-00T00:00:00Z" . renderRfc3339String

instance IsString Rfc3339Time where
  fromString = fromMaybe commonEpoch . parseRfc3339String

instance GregorianCalendar Rfc3339Time where
  commonEpoch
    = Rfc3339Time
      { gdtYear           = 0
      , gdtMonth          = 1
      , gdtDay            = 1
      , gdtHour           = 0
      , gdtMinute         = 0
      , gdtSecond         = 0
      , gdtSecondFraction = 0
      , gdtOffset       = Just 0
      }
  getYear gt
    = return (gdtYear gt)
  getMonth gt
    = return (gdtMonth gt)
  getDay gt
    = return (gdtDay gt)
  getHour gt
    = return (gdtHour gt)
  getMinute gt
    = return (gdtMinute gt)
  getSecond gt
    = return (gdtSecond gt)
  getSecondFraction gt
    = return (gdtSecondFraction gt)

  setYear x gt
    = validate $ gt { gdtYear           = x }
  setMonth x gt
    = validate $ gt { gdtMonth          = x }
  setDay x gt
    = validate $ gt { gdtDay            = x }
  setHour x gt
    = validate $ gt { gdtHour           = x }
  setMinute x gt
    = validate $ gt { gdtMinute         = x }
  setSecond x gt
    = validate $ gt { gdtSecond         = x }
  setSecondFraction x gt
    = validate $ gt { gdtSecondFraction = x }

instance LocalOffset Rfc3339Time where
  getLocalOffset
    = return . gdtOffset
  setLocalOffset mm gt
    = validate $ gt { gdtOffset = mm }
