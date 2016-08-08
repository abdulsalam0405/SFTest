/*
 * Get Current Cursor Position
 */
function NumbersOnly(event,Input,bAllowDecimals,iDecimalUpTo) 
{
	var charCode = (event.which) ? event.which : event.keyCode
	
	var sCurrentValue = Input.value;
		
	if (bAllowDecimals) 
	{
		if (charCode==46) 
		{
			if(parseFloat(sCurrentValue.indexOf(".")) > 0 && !isTextSelected(Input))
				return false;
			else 
				return true;
		}
		else if(charCode > 31 && (charCode < 48 || charCode > 57)) 
		{
			return false;				
		}
		else 
		{
			var iCurrentIndex = getCaretPos(Input);
			
			if(charCode!=8 &&  (charCode < 31 || charCode > 45)) 
			{
				if(parseFloat(sCurrentValue.indexOf(".")) > 0 && iCurrentIndex > sCurrentValue.indexOf(".")) 
				{
					var DigitsAfterDecimal = sCurrentValue.split('.')[1];
					if(DigitsAfterDecimal.length < iDecimalUpTo)
						return true;
					else
						if(charCode==9)
							return true;
						else
							return false;
				}
			}
		}
	} 
	else 
	{
		if (charCode > 31 && (charCode < 48 || charCode > 57))
			return false;
	}
	return true;
}

/*
 * Get Current Cursor Position
 */
function getCaretPos(input) 
{
	// Internet Explorer Caret Position (TextArea)
	if (document.selection && document.selection.createRange) 
	{
		var range = document.selection.createRange();
		var bookmark = range.getBookmark();
		var caret_pos = bookmark.charCodeAt(2) - 2;
	}
	else 
	{
		// Firefox Caret Position (TextArea)
		if (input.setSelectionRange)
			var caret_pos = input.selectionStart;
	}

	return caret_pos;
}

/*
 * Check and Return boolean value based on text selection
 */
function isTextSelected(input) 
{
	if (typeof input.selectionStart == "number") 
	{
		return input.selectionStart == 0 && input.selectionEnd == input.value.length;
	}
	else if (typeof document.selection != "undefined") 
	{
		input.focus();
		return document.selection.createRange().text == input.value;
	}
}