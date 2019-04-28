{-# LANGUAGE OverloadedStrings #-}

module Api.User where

import           Network.HTTP.Types
import           Web.Spock
import           Web.Spock.Config

import           Data.Aeson              hiding (json)
import           Data.Text               (Text, pack)

import           Database.Persist        hiding (delete, get)
import qualified Database.Persist        as P
import           Database.Persist.Sqlite hiding (delete, get)
import           Database.Persist.TH

import           ApiTypes
import           Errors
import           Models

getUsers :: SpockCtxM ctx SqlBackend sess st ()
getUsers =
  get "users" $ do
    users <- runSQL $ selectList [] [Asc UserId]
    json users

getUser :: SpockCtxM () SqlBackend () () ()
getUser =
  get ("users" <//> var) $ \userId -> do
    mu <- runSQL $ P.get userId :: ApiAction (Maybe User)
    case mu of
      Nothing   -> setStatus status404 >> handler 2 "User not found"
      Just user -> setStatus status200 >> json user

deleteUser :: SpockCtxM () SqlBackend () () ()
deleteUser =
  delete ("users" <//> var) $ \userId -> do
    mu <- runSQL $ P.get userId :: ApiAction (Maybe User)
    case mu of
      Nothing -> setStatus status404 >> handler 2 "User not found"
      Just _  -> do
        runSQL $ P.delete (userId :: UserId)
        setStatus status204

postUser :: SpockCtxM () SqlBackend () () ()
postUser =
  post "users" $ do
    mu <- jsonBody :: ApiAction (Maybe User)
    case mu of
      Nothing -> setStatus status400 >> handler 1 "Failed to parse request body as User"
      Just user -> do
        id <- runSQL $ insert user
        setStatus status201
        json $ object ["result" .= String "success", "id" .= id]