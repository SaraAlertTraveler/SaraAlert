import LANGUAGES from '../data/minifiedLanguages.json'
import supportedLanguages from '../data/supportedLanguages'
import _ from 'lodash'

// Attempts to match
function tryToMatchLanguage (potentialCodeorLanguage) {
  if (!potentialCodeorLanguage) return false
  let matchedLang = LANGUAGES.find(o => o.c === potentialCodeorLanguage);
  if (!matchedLang) {
    matchedLang = LANGUAGES.find(o => o.d === potentialCodeorLanguage);
  }
  return matchedLang
}

// gets the `supported` messaging options for a specific language
// Note: the language passed in should in the format
// {c: isoCode, d: displayName}
function getLanguageSupported(language = {c:null, d:null}) {
  let supportedLanguageReference = supportedLanguages.find(y => y.name === language.d)
  if (supportedLanguageReference) {
    supportedLanguageReference["code"] = language.c
  } else {
    supportedLanguageReference = {
      "name": language.d,
      "code": language.c,
      "supported": {
        "sms": false,
          "email": false,
          "phone": false
        }
      }
    }
    return supportedLanguageReference
}

// gets the languages options formatted for the Select Dropdown
function getLanguagesAsOptions () {
  let allLangs = LANGUAGES.map(x => getLanguageSupported(x))
  allLangs = allLangs.sort((a, b) => a.name.localeCompare(b.name))
  const langOptions = allLangs.map(lang => {
    const fullySupported = lang.supported.sms && lang.supported.email && lang.supported.phone;
    const langLabel = fullySupported ? lang.name : lang.name + '*';
    return { value: lang.code, label: langLabel };
  });

  // lodash's 'remove()' actually removes the values from the object
  let supportedLangCodes = supportedLanguages.map(sL => sL.code);
  const supportedLangsFormatted = _.remove(langOptions, n => supportedLangCodes.includes(n.value));
  const unsupportedLangsFormatted = langOptions;

  const groupedOptions = [
    {
      label: 'Supported Languages',
      options: supportedLangsFormatted,
    },
    {
      label: 'Unsupported Languages',
      options: unsupportedLangsFormatted,
    },
  ];
  return groupedOptions;
};

function convertLanguageCodeToName (val) {
  const matchedLang = LANGUAGES.find(o => o.c === val)
  return  matchedLang ? matchedLang.d : ''
}

function convertLanguageNameToISOCode (val) {
  const matchedLang = LANGUAGES.find(o => o.d === val)
  return  matchedLang ? matchedLang.c : ''
}

export {
  LANGUAGES,
  tryToMatchLanguage,
  getLanguagesAsOptions,
  getLanguageSupported,
  convertLanguageCodeToName,
  convertLanguageNameToISOCode
};