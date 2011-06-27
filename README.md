# FSMarkdownLoader

Using a very loose sort of non-schema, loads key/value data from a Markdown file.

## Requirements

* Objective-C and the Apple Foundation library (or some equivalent)
* RegexKitLite

## Example

Example of Markdown source:

	This is a Markdown file.

	**This is a key**: `and a value`

	# This is a header  
	**A generic key**: `value`  

	## And a subheader  
	**With another key**: `which has`, `two values`

	# And another header  
	I can include a description at the top  
	**With my final key**: `5` and I can actually just type here to comment things if I so choose  
	I can also include a description at the bottom.

Run through `FSMarkdownLoader`, it will generate this:

	INFO: Interpeted Markdown: {
	    "And another header" =     {
	        "With my final key" = 5;
	    };
	    "This is a header" =     {
	        "A generic key" = value;
	        "With another key" =         (
	            "which has",
	            "two values"
	        );
	    };
	    "This is a key" = "and a value";
	}

The output is intelligent and what you might expect it to be. An `NSDictionary` with `NSNumber` objects for numbers and booleans, `NSNull` for `~`, `NSDictionary`s for sub-headers, and `NSString` for anything and everything else. Multiple values for a single key are put into an `NSArray`.