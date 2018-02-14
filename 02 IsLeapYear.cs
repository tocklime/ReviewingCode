// The MIT License (MIT)
//
// Copyright (c) 2018 ACompany. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// Contains methods for working with leap years
// Change History
// 1.0  D.Betteridge   13th Feb 2018 - first version
// 1.1  M.Mouse        14th Feb 2018 - renamed variables


// Method: IsLeapYear
// Usage: Checks to see if the given year is a leap year
// Arguments:  Year (int) the year to check
// Returns:  Bool - True if it's a leap year,  False otherwise
bool IsLeapYear(int year)
{
    if ((year % 4) != 0) return false;   //Check to see if it can be divided by 4
    if ((year % 100) != 0) return true;  //Check to see if it can be divided by 100
    return ((year % 400) != 0);          //Check to see if it can be divided by 400
}

// Initial version changed by M.Mouse (14th Feb 2018)
//bool IsLeapYear(int Year)
//{
//    if ((Year % 4) != 0) return false;   //Check to see if it can be divided by 4
//    if ((Year % 100) != 0) return true;  //Check to see if it can be divided by 100
//    return ((Year % 400) != 0);          //Check to see if it can be divided by 400
//}

//                                              End of Code