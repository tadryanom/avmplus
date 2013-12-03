/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// From: http://lxr.mozilla.org/mozilla/source/extensions/xml-rpc/src/nsXmlRpcClient.js#956

package {
/* Convert data (an array of integers) to a Base64 string. */
var toBase64TableString:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
var toBase64Table:Array = toBase64TableString.split('');

var base64Pad:String = '=';

function toBase64(data:String):String {
    var result:String = '';
    var length:uint = data.length;
    var i:uint;
    // Convert every three bytes to 4 ascii characters.
    for (i = 0; i < (length - 2); i += 3) {
        result += toBase64Table[data.charCodeAt(i) >> 2];
        result += toBase64Table[((data.charCodeAt(i) & 0x03) << 4) + (data.charCodeAt(i+1) >> 4)];
        result += toBase64Table[((data.charCodeAt(i+1) & 0x0f) << 2) + (data.charCodeAt(i+2) >> 6)];
        result += toBase64Table[data.charCodeAt(i+2) & 0x3f];
    }

    // Convert the remaining 1 or 2 bytes, pad out to 4 characters.
    if (length%3) {
        i = length - (length%3);
        result += toBase64Table[data.charCodeAt(i) >> 2];
        if ((length%3) == 2) {
            result += toBase64Table[((data.charCodeAt(i) & 0x03) << 4) + (data.charCodeAt(i+1) >> 4)];
            result += toBase64Table[(data.charCodeAt(i+1) & 0x0f) << 2];
            result += base64Pad;
        } else {
            result += toBase64Table[(data.charCodeAt(i) & 0x03) << 4];
            result += base64Pad + base64Pad;
        }
    }

    return result;
}

/* Convert Base64 data to a string */
var toBinaryTable:Array = [
    -1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1,
    -1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1,
    -1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,62, -1,-1,-1,63,
    52,53,54,55, 56,57,58,59, 60,61,-1,-1, -1, 0,-1,-1,
    -1, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,
    15,16,17,18, 19,20,21,22, 23,24,25,-1, -1,-1,-1,-1,
    -1,26,27,28, 29,30,31,32, 33,34,35,36, 37,38,39,40,
    41,42,43,44, 45,46,47,48, 49,50,51,-1, -1,-1,-1,-1
];

function base64ToString(data:String):String {
    var result = '';
    var leftbits:uint = 0; // number of bits decoded, but yet to be appended
    var leftdata:uint = 0; // bits decoded, but yet to be appended

    // Convert one by one.
    for (var i:uint = 0; i < data.length; i++) {
        var c:int = toBinaryTable[data.charCodeAt(i) & 0x7f];
        var padding:Boolean = (data.charCodeAt(i) == base64Pad.charCodeAt(0));
        // Skip illegal characters and whitespace
        if (c == -1) continue;
        
        // Collect data into leftdata, update bitcount
        leftdata = (leftdata << 6) | c;
        leftbits += 6;

        // If we have 8 or more bits, append 8 bits to the result
        if (leftbits >= 8) {
            leftbits -= 8;
            // Append if not padding.
            if (!padding)
                result += String.fromCharCode((leftdata >> leftbits) & 0xff);
            leftdata &= (1 << leftbits) - 1;
        }
    }

    // If there are any bits left, the base64 string was corrupted
    if (leftbits)
        throw new Error('Corrupted base64 string');

    return result;
}

// main entry point for running testcase
function runTest():void {
var str:String = "";

for ( var i:uint = 0; i < 8192; i++ )
        str += String.fromCharCode( (25 * Math.random()) + 97 );

for ( var i:uint = 8192; i <= 16384; i *= 2 ) {

    var base64;

    base64 = toBase64(str);
    base64ToString(base64);

    // Double the string
    str += str;
}

//toBinaryTable = null;
} //runTest()

// warm up run of testcase
runTest();
var startTime:uint = new Date().getTime();
runTest();
var time:uint = new Date().getTime() - startTime;
print("metric time " + time);

} //package