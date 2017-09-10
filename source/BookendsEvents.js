// groupIDs :: String -> [String]
function groupIDs(strGroupName) {
  // "All". "Hits", "Attachments", "Selection" or custom group name
  return evalOSA(
      '', eventCode('RUID') +
      ' "' + (strGroupName || '') + '"'
    )
    .split('\r');
}

// sqlMatchIDs :: String -> [String]
function sqlMatchIDs(strClause) {
  // SELECT clause without the leading SELECT keyword
  var strResult = evalOSA(
    '', eventCode('SQLS') +
    ' "' + strClause + '"'
  );

  return strResult.indexOf('\r') !== -1 ? (
    strResult.split('\r')
  ) : (strResult ? [strResult] : []);
}

// formattedRefs :: [String] -> maybe Boolean -> maybe String -> String
function formattedRefs(ids, blnRTF, strFormat) {
  return evalOSA(
      '', eventCode('GUID') +
      ' "' + (ids instanceof Array ? ids : [ids])
      .join(',') + '" given «class RRTF»:"' +
      (blnRTF ? 'true' : 'false') + '", string:"' +
      strFormat + '"'
    )
    .split('\r')
    .slice(0, -1); // except trailling empty string
}

// customGroupNames :: () -> [String]
function customGroupNames() {
  return evalOSA(
      '', eventCode('RGPN')
    )
    .split('\r');
}

// fieldContents [String] -> maybe String -> String
function fieldContents(ids, maybeFieldName) {
  // authors, title, editors, journal, volume, pages, thedate,
  // publisher, location, url, title2, abstract, notes, user1...user20

  return evalOSA(
      '', eventCode('RFLD') +
      ' "' + (ids instanceof Array ? ids : [ids])
      .join(',') + '"' +
      (maybeFieldName ? (
        ' given string:' +
        '"' + maybeFieldName + '"'
      ) : '')
    )
    .split(String.fromCharCode(0));
}

// fieldWrite :: String -> String -> String -> ()
function fieldWrite(strID, strFieldName, strValue) {
  // authors, title, editors, journal, volume, pages, thedate,
  // publisher, location, url, title2, abstract, notes, user1...user20
  return (
    evalOSA(
      '', eventCode('SFLD') +
      ' "' + strID + '" given «class FLDN»:"' +
      strFieldName + '", string:"' + strValue + '"'
    ), strValue
  );
}

// modificationDates :: [String] -> [Date]
function modificationDates(ids) {

  return evalOSA(
      '', eventCode('RMOD') +
      ' "' + (ids instanceof Array ? ids : [ids])
      .join(',') + '"'
    )
    .split(String.fromCharCode(0))
    .map(function (s) {
      var dte = new Date(
        // Need Unix (1970) milliseconds (not 1904 seconds) for JS:
        // (drop 66 years of seconds, and convert to milliseconds)
        (parseInt(s, 10) - 2.0828448E+9) * 1000
      );

      return dte;
    });
}

// recordAdded :: maybe String -> maybe Dictionary -> String
function recordAdded(maybeFilePath, maybeDictionary) {
  // arg1: maybe Posix path to attachment
  // arg2: maybe dictionary of RIS key:value pairs
  // returns ID of new record
  return (maybeFilePath || maybeDictionary) ? (
    evalOSA(
      '', eventCode('ADDA') +

      (maybeFilePath ? (
        ' "' + $(maybeFilePath)
        .stringByStandardizingPath.js + '"'
      ) : '') +

      (maybeDictionary ? (
        ' given «class RIST»:"' +
        Object.keys(maybeDictionary)
        .reduce(function (a, strKey) {
          var k = strKey.toUpperCase();

          return k !== 'TY' ? (
            a + k + ' - ' +
            maybeDictionary[
              strKey
              ] + '\n'
          ) : a;
        }, ('TY - ' + (
          maybeDictionary['TY'] ||
          maybeDictionary[
            'ty'
            ] || 'JOUR'
        ) + '\n')) + '"'
      ) : '')
    )
    .split('\n')[0]
  ) : undefined;
}


// evalOSA :: String -> String -> IO String
function evalOSA(strLang, strCode) {
  
  var oScript = ($.OSAScript || (
      ObjC.import('OSAKit'),
      $.OSAScript))
    .alloc.initWithSourceLanguage(
      strCode, $.OSALanguage.languageForName(strLang)
    ),
    error = $(),
    blnCompiled = oScript.compileAndReturnError(error),
    oDesc = blnCompiled ? (
      oScript.executeAndReturnError(error)
    ) : undefined;

  return oDesc ? (
    oDesc.stringValue.js
  ) : error.js.NSLocalizedDescription.js;
}

// eventCode :: String -> String
function eventCode(strCode) {
  return 'tell application "Bookends" to «event ToyS' +
    strCode + '»';
}