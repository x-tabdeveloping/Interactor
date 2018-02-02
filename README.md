# The Interactor Module

The reason I created this library and the Interactor typeclass, is that the GTK Haskell library made alot of things really messy.
I think in a functional language computations should be separated from IO, and the GTK library messes up the whole thing.
So I thought it would be a great idea to come up with a simple way of getting input and handling output with GTK and
different methods.

## The Interactor Typeclass

```haskell
class Interactor s where
    see :: (Show a) => s a -> IO()
    getIt :: (Show a) => s a -> IO String
```

As you can tell from this little chunk of code, the class isn't supposed to be implemented for concrete types, but for type constructors.
It's also pretty obvious, that the see function is actually for handling Output and the getIt function works as input.

let's see an example of an instance of the Interactor class :
```haskell
data Printer a = Printer (Maybe a)

instance Interactor Printer where
    see (Printer (Just x)) = print x
    see (Printer Nothing) = return ()
    getIt (Printer (Just x)) = do
        x -| (see . Printer)
        s <- getLine
        return s
    getIt (Printer Nothing) = getLine
```

basically Printer is just using the console as an IO source.

There's this nasty little infix function, which you might have already noticed : `(-|)`
I wrote it just in order to make these interactions look a lot less scary, here goes it's type signature :
```haskell
(-|) :: a -> (Maybe a -> b) -> b
```

Now let's see how we could use out Printer Interactor:
```haskell
main = do
	x <- "Please enter your name" -| (getIt . Printer)
	"hello" ++ x -| (see . Printer)
```

Well, this might look a little overcomplicated at this point, but you'll see the point of it I promise.

Still we have a problem with this little program though:
Instead of printing : `Please enter your name` it prints us ` "Please enter your name" `
Now to fix this issue, I've come up with a datatype : `ShowString`
let's consider the following, fixed example: ```haskell
main = do
	x <- ShowString("Please enter your name") -| (getIt . Printer)
	ShowString ("hello" ++ x) -| (see . Printer)
```

This behavior has also an advantage though: we don't have to show other types every single time.
So every type that implements the Show class will show up correctly on our output.

So why would you even bother with all this stuff?

Well, what if you wanted to use a GTK+ window as an IO source?

You can just go like this :
```haskell
main = do
	x <- ShowString ("Please enter your name") -| (getIt . Message)
	ShowString ("hello" ++ x) -| (see . Message)
```

A little less noisy than average GTK+ code, isn't it? 
