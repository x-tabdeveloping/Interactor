module Interactor
(Printer(..),
Message(..),
Notification(..),
ShowString(..),
(-|),
Interactor,
see,
getIt)
 where

import Control.Concurrent
import Control.Monad
import Control.Monad.IO.Class
import Data.IORef
import Graphics.UI.Gtk --hiding (Action, backspace)
import Graphics.UI.Gtk.Layout.VBox
import System.Process

data Printer a = Printer (Maybe a)
data Message a = Message (Maybe a)
data Notification a = Notification (Maybe a)

data ShowString = ShowString String

instance Show ShowString where
    show (ShowString x) = x 

class Interactor s where
    see :: (Show a) => s a -> IO()
    getIt :: (Show a) => s a -> IO String

(-|) :: a -> (Maybe a -> b) -> b
x -| f = f (Just x)

instance Interactor Printer where
    see (Printer (Just x)) = print x
    see (Printer Nothing) = return ()
    getIt (Printer (Just x)) = do
        x -| (see . Printer)
        s <- getLine
        return s
    getIt (Printer Nothing) = getLine

instance Interactor Message where
    see (Message (Just x)) = do
        void initGUI
        window <- windowNew
        set window [windowTitle := "Message", windowDefaultWidth := 500, windowDefaultHeight := 200]
        windowSetPosition window WinPosCenter
        label <- labelNew $ Just $ show x
        containerAdd window label
        window `on` deleteEvent $ do
            liftIO mainQuit
            return False
        widgetShowAll window
        mainGUI
    see (Message Nothing) = return ()
    getIt (Message (Just x)) = do
        retVal <- newIORef "Default"
        void initGUI
        window <- windowNew
        set window [windowTitle := (show x), windowDefaultWidth := 500, windowDefaultHeight := 200]
        windowSetPosition window WinPosCenter
        entry <- entryNew
        button <- buttonNew
        set button [ buttonLabel := "Enter" ]
        grid <- vBoxNew True 0
        window `on` deleteEvent $ do
            liftIO mainQuit
            return False
        button `on` buttonActivated $ do
            entryGetText entry >>= writeIORef retVal
            widgetHideAll window
            windowSetDestroyWithParent window True
            liftIO mainQuit
        boxPackEndDefaults grid button
        boxPackEndDefaults grid entry 
        containerAdd window grid
        widgetShowAll window
        mainGUI
        x <- readIORef retVal
        return x

    getIt (Message Nothing) = getIt (Message (Just "Message"))

instance Interactor Notification where
    see (Notification (Just x)) = do
        code <- system $ "notify-send " ++ "Notification" ++ " \"" ++ (show x) ++ "\""
        return ()
    see (Notification Nothing) = return ()
    getIt (Notification (Just x)) = do
        x -| (see . Notification)
        s <- getLine
        return s
    getIt (Notification Nothing) = getLine