//
//  VariantGenerator.swift
//  vietdictionaryapp
//
//  Created by Michael Tran on 16/8/20.
//  Copyright © 2020 Michael Tran. All rights reserved.
//

import Foundation

// TODO: change all the variations to StackResult calls!!

public enum VariantType
{
    case fromSpellingToRealPronunciation, // tin -> tinh SG,
    fromPronunciationToActualSpelling, // tinh -> tin SG, nhăng -> nhanh HN
    homophones, // da, gia, ra in north, da, va, gi in southern
    asInputted,
    spellingVariation,
    useExplaination
}

public struct VariationReason : Hashable
{
    /*static func == (lhs: VariationReason, rhs: VariationReason) -> Bool {
     return lhs.reason == rhs.reason && lhs.variantType == rhs.variantType
     }
     
     public func hash(into hasher: inout Hasher) {
     hasher.combine(self.reason)
     hasher.combine(self.variantType)
     }*/
    
    init(reason: String, region: String, variantType: VariantType = .homophones)
    {
        self.reason = reason
        self.region = region
        self.variantType = variantType
    }
    
    var reason: String
    var variantType: VariantType
    var region: String
}

struct PronunciationVariant : Hashable
{
    static func == (lhs: PronunciationVariant, rhs: PronunciationVariant) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.originalWord)
        hasher.combine(self.variantWord)
    }
    
    init(baseVariant: String, operatingWord: OperatingWord, variationReason: VariationReason)
    {
        self.originalWord = baseVariant
        self.variantWord = operatingWord.extractWord()
        self.variationReason = variationReason
        self.rootOperatingWord = operatingWord
    }
    
    init(word: String, region: String)
    {
        self.originalWord = word
        self.variantWord = word
        self.variationReason = VariationReason(reason: "CODE" /* get rid of this */, region: region)
        self.rootOperatingWord = OperatingWord() // sohuldn't need to use this
    }
    
    init(explainationText: String)
    {
        self.originalWord = ""
        self.variantWord = explainationText
        self.variationReason = VariationReason(reason: "CODE", region: "")
        variationReason.variantType = .useExplaination
        self.rootOperatingWord = OperatingWord() // sohuldn't need to use this

    }
    
    var originalWord: String
    var variantWord: String
    var variationReason: VariationReason
    
    var rootOperatingWord: OperatingWord
}

struct OperatingWord {
    var initial: String = ""
    var core: String = ""
    var cleanCore: String = ""
    var final: String = ""
    var toneIndex: Int = -1
    
    // Get a complete word out of the internal representation
    func extractWord() -> String
    {
        var coreRestoredVowel = ""
        if (toneIndex > 0)
        {
            let toneCarrierChar = getToneCarrierCharacter()
            let vowelTableLookup = VariantGenerator.vowelTable2[toneCarrierChar]
            if vowelTableLookup != nil
            {
                let retonedVowel = vowelTableLookup![toneIndex]
                coreRestoredVowel = cleanCore.replacingOccurrences(of: toneCarrierChar, with: retonedVowel)
            }
            else
            {
                coreRestoredVowel = "BUG!! looking up vowel/tone to restore failed"
            }
        }
        else
        {
            coreRestoredVowel = cleanCore
        }
        
        return initial + coreRestoredVowel + final
    }
    
    // Returns the character in the string that should carry the tone marker
    // probably doesn't handle soóc
    func getToneCarrierCharacter() -> String
    {
        for (index, result) in toneCarrierCharacterTable
        {
            if cleanCore.contains(index)
            {
                return result
            }
        }
        
        if final.count > 0
        {
            let lastVowel = String(cleanCore.suffix(1))
            return lastVowel
        }
        
        // second to last vowel
        
        var vowelIndex = -1
        if (cleanCore.count == 1)
        {
            vowelIndex = 0
        }
        else
        {
            vowelIndex = cleanCore.count - 1 - 1 // one for zero indexing, one for penultimate
        }
        
        // Todo: bing in a fguckin' string libary
        let charArray = Array(cleanCore)
        let char = charArray[vowelIndex]
        return String(char)
    }
    
    let toneCarrierCharacterTable = [
        "ươ" : "ơ",
        "ă" : "ă",
        "â" : "â",
        "ê" : "ê",
        "ô" : "ô",
        "ơ" : "ơ",
        "ư" : "ư"
    ]
}

class VariantGenerator
{
    
    static private var vowelTableNoClean = [
        "oó" : "oó",
        "a": "[áàảạã]",
        "â": "[ấầẩậẫ]",
        "ă": "[ắằẳặẵ]",
        "e": "[éèẻẹẽ]",
        "ê": "[ếềểệễ]",
        "i": "[íìỉịĩ]",
        "o": "[óòỏọõ]",
        "ô": "[ốồổộỗ]",
        "ơ": "[ớờởợỡ]",
        "u": "[úùủụũ]",
        "ư": "[ứừửựữ]",
        "y": "[ýỳỷỵỹ]"
    ]
    
    static private var vowelTable = [
        "oó" : "oó",
        "a": "[aáàảạã]",
        "â": "[âấầẩậẫ]",
        "ă": "[ăắằẳặẵ]",
        "e": "[eéèẻẹẽ]",
        "ê": "[êếềểệễ]",
        "i": "[iíìỉịĩ]",
        "o": "[oóòỏọõ]",
        "ô": "[ôốồổộỗ]",
        "ơ": "[ơớờởợỡ]",
        "u": "[uúùủụũ]",
        "ư": "[ưứừửựữ]",
        "y": "[yýỳỷỵỹ]"
    ]
    
    static public var vowelTable2 = [
        "oó" : ["oó"],
        "a": ["a", "á", "à", "ả", "ạ", "ã"],
        "â": ["â", "ấ", "ầ", "ẩ", "ậ", "ẫ"],
        "ă": ["ă", "ắ", "ằ", "ẳ", "ặ", "ẵ"],
        "e": ["e", "é", "è", "ẻ", "ẹ", "ẽ"],
        "ê": ["ê", "ế", "ề", "ể", "ệ", "ễ"],
        "i": ["i", "í", "ì", "ỉ", "ị", "ĩ"],
        "o": ["o", "ó", "ò", "ỏ", "ọ", "õ"],
        "ô": ["ô", "ố", "ồ", "ổ", "ộ", "ỗ"],
        "ơ": ["ơ", "ớ", "ờ", "ở", "ợ", "ỡ"],
        "u": ["u", "ú", "ù", "ủ", "ụ", "ũ"],
        "ư": ["ư", "ứ", "ừ", "ử", "ự", "ữ"],
        "y": ["y", "ý", "ỳ", "ỷ", "ỵ", "ỹ"]
    ]
    
    // - / \ ? . ~
    
    static let TONEINDEX_NGANG = 0
    static let TONEINDEX_SAC = 1
    static let TONEINDEX_HUYEN = 2
    static let TONEINDEX_HOI = 3
    static let TONEINDEX_NANG = 4
    static let TONEINDEX_NGA = 5
    
    static private var toneTableArray = [
        "[aâăeêioôơuưy]",
        "[áấắéếíóốớúứý]",
        "[àầằèềìòồờùừỳ]",
        "[ảẩẳẻểỉỏổởủửỷ]",
        "[ạậặẹệịọộợụựỵ]",
        "[ãẫẵẽễĩõỗỡũữỹ]",
    ]
    
    static public func GenerateVariantsMultipleSyllables(words: String) -> Array<PronunciationVariant>
    {
        var arrayOfVariants = Array<Array<PronunciationVariant>>()
        let components = words.components(separatedBy: " ")
        
        for component in components
        {
            var fullVariants = generateVariants(baseVariant: component)
            if (components.count > 1)
            {
                fullVariants.insert(PronunciationVariant(word: component, region: "INPUT"), at: 0)
            }
            arrayOfVariants.append(fullVariants)
        }
        
        var generatedVariants = Array<PronunciationVariant>()
        
        // FilloutVariants(resultsArray: &generatedVariants, inputs: arrayOfVariants, indexIntoInput: 0, variantSoFar: "", regionSoFar: "Everyone")
        
        if arrayOfVariants.count > 1
        {
            for variant in arrayOfVariants[0]
            {
                FilloutVariants(resultsArray: &generatedVariants, inputs: arrayOfVariants, indexIntoInput: 1, variantSoFar: variant.variantWord, regionSoFar: variant.variationReason.region)
                
            }
        }
        else
        {
            return arrayOfVariants[0]
        }
        
        return generatedVariants
    }
    
    static public func FilloutVariants(resultsArray: inout Array<PronunciationVariant>, inputs: Array<Array<PronunciationVariant>>, indexIntoInput: Int, variantSoFar: String, regionSoFar: String)
    {
        let variants = inputs[indexIntoInput]
        
        // var newVariants = Array<PronunciationVariant>()
        
        for variant in variants
        {
            if IsRegionInCandidates(region: regionSoFar, candidateRegions: variant.variationReason.region)
            {
                var newRegion = ""
                
                if (regionSoFar == "INPUT")
                {
                    newRegion = variant.variationReason.region
                }
                else if (variant.variationReason.region == "INPUT")
                {
                    newRegion = regionSoFar
                }
                else
                {
                    // ... get subset...
                }
                
                var gap = ""
                if indexIntoInput > 0
                {
                    gap = " "
                }
                let thisVariant = variantSoFar + gap + variant.variantWord
                let thisPrnVariant = PronunciationVariant(word: thisVariant, region: newRegion)
                
                // TODO: pare down the regions
                if (indexIntoInput == inputs.count - 1)
                {
                    resultsArray.append(thisPrnVariant)
                }
                else
                {
                    FilloutVariants(resultsArray: &resultsArray, inputs: inputs, indexIntoInput: indexIntoInput + 1, variantSoFar: thisVariant, regionSoFar: newRegion)
                }
            }
        }
    }
    
    static public func IsRegionInCandidates(region: String, candidateRegions: String) -> Bool
    {
        if region == "Everyone" || candidateRegions == "Everyone"
        {
            return true
        }
        
        if region == "Input"
        {
            return true
        }
        
        // TODO:
        // finish diz
        
        return true // fix me
    }
    
    static public func generateVariants(baseVariant :String) -> Array<PronunciationVariant>
    {
        var generatedVariants = Array<PronunciationVariant>()
        
        var baseWord = OperatingWord()
        
        let initialsTable = ["nh", "ngu", "ngh", "ng", "r", "gi", "gh", "g", "d", "đ", "v", "ph", "p", "ch", "c", "th", "tr", "t", "b", "h", "kh", "k", "l", "m", "n", "s", "x", "qu",
        
            // initials after here are not spelt, just said
            
            "wu", "rr", "z"
        
        ]
        
        let finalsTable = ["ng", "n", "t", "c", "p", "k", "p", "nh", "m", "ch"]
        
        var matchedFrom = ""
        var matchedTo = ""
        
        var wordCutup = baseVariant.lowercased()
        
        for initial in initialsTable
        {
            if wordCutup.hasPrefix(initial)
            {
                baseWord.initial = initial
                wordCutup = String(wordCutup.dropFirst(initial.count))
                break;
            }
        }
        
        for final in finalsTable
        {
            if wordCutup.hasSuffix(final)
            {
                baseWord.final = final
                wordCutup = String(wordCutup.dropLast(final.count))
                break;
            }
        }
        
        baseWord.core = wordCutup
        
        // Scan the word to figure out the tone.
        for (index, pattern) in VariantGenerator.vowelTableNoClean
        {
            let regexp = BasicRegexWrapper(pattern: pattern)
            let matches = regexp.getMatchesInString(input: baseWord.core)
            if matches.count > 0
            {
                matchedFrom = matches[0]
                matchedTo = index
                // strip the tone marker to find the "toneless" core vowel of the word
                baseWord.cleanCore = baseWord.core.replacingOccurrences(of: matchedFrom, with: matchedTo, options: .regularExpression)
                
                for (index, toneRegexp) in VariantGenerator.toneTableArray.enumerated()
                {
                    // matched the tone marker character against a table to figure out the tone
                    let regexp = BasicRegexWrapper(pattern: toneRegexp)
                    let matches = regexp.getMatchesInString(input: matchedFrom)
                    if matches.count > 0
                    {
                        baseWord.toneIndex = index
                        break
                    }
                }
                break
            }
        }
               
        // if no tone marker was found, it's a thanh ngang
        if (baseWord.toneIndex == -1)
        {
            baseWord.toneIndex = 0 // thanh ngang
            baseWord.cleanCore = baseWord.core
        }
        
        // Some exceptions to simple analysis above
        // uy hiếm
        if baseWord.cleanCore == "uy" && baseWord.final.isEmpty && baseWord.initial.isEmpty
        {
            baseWord.initial = "u"
            baseWord.cleanCore = "y"
        }
        
        // Some exceptions to simple analysis above
        // uyễn
        if baseWord.cleanCore == "uyê" && baseWord.initial.isEmpty
        {
            baseWord.initial = "u"
            baseWord.cleanCore = "yê"
        }
        
        // Some exceptions to simple analysis above
        // yếu, but also handles fake syllables like yiệt
        if baseWord.cleanCore.first == "y" && baseVariant.count > 1 && baseWord.initial.isEmpty
        {
            baseWord.initial = "y"
            baseWord.cleanCore = String(baseWord.cleanCore.dropFirst())
        }
        
        // Use this if you want any given variant generation block to stack upon any previously generated variant.
        func StackResults(results: inout Array<PronunciationVariant>, originalTerm: String, operatingWord: OperatingWord, closure: (_ operatingWord: OperatingWord) -> (OperatingWord, VariationReason))
        {
            for existingEntry in results
            {
                var closureResult = closure(existingEntry.rootOperatingWord)
                closureResult.1.reason = "➕\(closureResult.1.reason)"
                let newVariant = PronunciationVariant(baseVariant: baseVariant, operatingWord: closureResult.0, variationReason: closureResult.1)
                results.append(newVariant)
            }
            
            let closureResult = closure(operatingWord)
            let newVariant = PronunciationVariant(baseVariant: baseVariant, operatingWord: closureResult.0, variationReason: closureResult.1)
            results.append(newVariant)
        }
        
        // ---------- Saigon/South ------------
        
        // đếm -> đím
        if baseWord.cleanCore == "ê" && (baseWord.final == "m" || baseWord.final == "p")
        {
            var createdVariant = baseWord
            createdVariant.cleanCore = "i"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "pronounce ê like i", region: "Western; Southern - more common in older speakers, children and diaspora Vietnamese (most common examples: bếp -> 'bíp', đếm -> 'đím')", variantType: .fromSpellingToRealPronunciation)))
        }
        
        // corollary of above
        if baseWord.cleanCore == "i" && (baseWord.final == "m" || baseWord.final == "p")
        {
            var createdVariant = baseWord
            createdVariant.cleanCore = "ê"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "pronounce ê like i", region: "Western; Southern - more common in older speakers, children and diaspora Vietnamese (most common examples: bếp -> 'bíp', đếm -> 'đím')", variantType: .fromPronunciationToActualSpelling)))
        }
        
        // thuê -> thê TODO: -> thơi?
        // TODO: needs corollary
        if baseWord.cleanCore == "uê" && baseWord.final.isEmpty
        {
            var createdVariant = baseWord
            createdVariant.cleanCore = "ê"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "pronounce uê like ê because their accent does not have labialised sounds, this in turn might sound like thơi", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
        }
        // corollary of above
        if baseWord.cleanCore == "ê" && baseWord.final.isEmpty
        {
            var createdVariant = baseWord
            createdVariant.cleanCore = "uê"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "pronounce uê like ê because their accent does not have labialised sounds, this in turn might sound like thơi", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.cleanCore == "ă"
        {
            var createdVariant = baseWord
            createdVariant.cleanCore = createdVariant.cleanCore.replacingOccurrences(of: "ă", with: "â")
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "pronounce â like ă", region: "Western; Southern; Central", variantType: .homophones)))
        }
        
        if baseWord.cleanCore == "â"
        {
            // corollary of above
            var createdVariant = baseWord
            createdVariant.cleanCore = createdVariant.cleanCore.replacingOccurrences(of: "â", with: "ă")
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "pronounce â like ă depending on surrounding consonants (lần -> lần)", region: "Western; Southern; Central", variantType: .homophones)))
            
            // TODO: needs corollary
            var createdVariantTwo = baseWord
            createdVariantTwo.cleanCore = createdVariantTwo.cleanCore.replacingOccurrences(of: "â", with: "ư")
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariantTwo, variationReason: VariationReason(reason: "pronounce â like ư depending on surrounding consonants (chân -> chưn(g))", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if baseWord.initial == "h" && baseWord.cleanCore == "oa"
        {
            var createdVariant = baseWord
            createdVariant.initial = "w"
            createdVariant.cleanCore = "a"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "(add word for this phenomenon) - some speakers reduce the labilisation (lip pursing) of ho- words to a w- sound; this is more more common outside of Saigon", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
            
            var createdVariantTwo = baseWord
            createdVariantTwo.initial = ""
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariantTwo, variationReason: VariationReason(reason: "(add word for this phenomenon) - some speakers reduce the labilisation (lip pursing) of ho- words to a w- sound; this is more more common outside of Saigon", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if (baseWord.initial == "w" && baseWord.cleanCore == "a") || (baseWord.initial.isEmpty && baseWord.cleanCore == "oa") // COROLLARY OF ABOVE
        {
            var createdVariant = baseWord
            createdVariant.initial = "h"
            createdVariant.cleanCore = "oa"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "(add word for this phenomenon) - some speakers reduce the labilisation (lip pursing) of ho- words to a w- sound", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.initial == "ngu"
        {
            var createdVariant = baseWord
            createdVariant.initial = "wu"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "ngu-, ho- and qu can all be pronounced like w-/-", region: "Western; Southern", variantType: .homophones)))
            
            var createdVariantSecond = baseWord
            createdVariantSecond.initial = "u"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariantSecond, variationReason: VariationReason(reason: "ngu-, ho- and qu can all be pronounced like w-/-", region: "Western; Southern")))
        }
        
        if baseWord.initial == "wu" // COROLLARY OF baseWord.initial == "ngu"
        {
            var createdVariant = baseWord
            createdVariant.initial = "ngu"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "ngu-, ho- and qu can all be pronounced like w-/-", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.initial == "u" && baseWord.cleanCore == "yê" // COROLLARY OF baseWord.initial == "ngu"
        {
            var createdVariant = baseWord
            createdVariant.initial = "ngu"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "ngu-, ho- and qu can all be pronounced like w-/-", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.initial == "qu"
        {
            var createdVariant = baseWord
            createdVariant.initial = "wu"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "ngu-, ho- and qu can all be pronounced like w-/-", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
            
            var createdVariantSecond = baseWord
            createdVariantSecond.initial = "u"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariantSecond, variationReason: VariationReason(reason: "ngu-, ho- and qu- can all be pronounced like w-/-", region: "Western; Southern")))
        }
        
        if baseWord.initial == "wu" // COROLLARY OF baseWord.initial == "qu"
        {
            var createdVariant = baseWord
            createdVariant.initial = "qu"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "ngu-, ho- and qu can all be pronounced like w-/-", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.initial.isEmpty && baseWord.cleanCore.hasPrefix("u") // COROLLARY OF baseWord.initial == "qu"
        {
            let remained = String(baseWord.cleanCore.dropFirst())
            if remained.hasPrefix("y") || remained.hasPrefix("ê") || remained.hasPrefix("ơ") || remained.hasPrefix("i")
            {
                var createdVariant = baseWord
                createdVariant.initial = "qu"
                createdVariant.cleanCore = remained
                generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "ngu-, ho- and qu can all be pronounced like w-/-", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
            }
        }
        
        if baseWord.initial == "u" && baseWord.cleanCore == "yê" // COROLLARY OF baseWord.initial == "qu"
        {
            var createdVariant = baseWord
            createdVariant.initial = "qu"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "ngu-, ho- and qu can all be pronounced like w-/-", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.initial == "u" && baseWord.cleanCore == "y"
        {
            var createdVariant = baseWord
            createdVariant.initial = "w"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "uy can be 'delabialised' and sound like wi/wy", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if baseWord.initial == "w" && (baseWord.cleanCore == "y" || baseWord.cleanCore == "i") // corollary of above
         {
             var createdVariant = baseWord
             createdVariant.initial = "u"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "uy can be 'delabialised' and sound like wi/wy", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
         }
        
        if baseWord.final == "t"
        {
            // exceptions: một, vịt
            if baseWord.cleanCore != "i" && baseWord.cleanCore != "ô" && baseWord.cleanCore != "u"
            {
                 // syntax note: part before 'in' can be expanded to: "(baseWord: OperatingWord) -> (OperatingWord, VariationReason)"
                 StackResults(results: &generatedVariants, originalTerm: baseVariant, operatingWord: baseWord) { baseWord in
                    var newVariant = baseWord
                    newVariant.final = "c"
                    return (newVariant, VariationReason(reason: "most -t endings in southern Vietnamese change depending on the vowel in front of it to (more commonly) -c, or (less commonly) -p", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation))
                }
                
                /*var newVariant = baseWord
                newVariant.final = "c"Ho
                generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "most -t endings in southern Vietnamese change depending on the vowel in front of it to (more commonly) -c, or (less commonly) -p", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))*/
            }
        }
        
        if baseWord.final == "c" // corollary of above
        {
            // exceptions: một, vịt
            if baseWord.cleanCore != "i" && baseWord.cleanCore != "ô" // check to match with abvove
            {
                 StackResults(results: &generatedVariants, originalTerm: baseVariant, operatingWord: baseWord) { baseWord in
                    var newVariant = baseWord
                    newVariant.final = "t"
                    return (newVariant, VariationReason(reason: "most -t endings in southern Vietnamese change depending on the vowel in front of it to (more commonly) -c, or (less commonly) -p", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling))
                }
            }
        }
        
        generatedVariants += HomophoneCoreSet(coreSet: ["iêu", "êu", "iu"], baseVariant: baseVariant, operatingWord: baseWord, reason: "-êu, -iêu and -iu all sound like -iu", region: "Western; Southern")
        
        generatedVariants += HomophonePrefixSet(prefixSet: ["gi", "d", "v"], baseVariant: baseVariant, operatingWord: baseWord, reason: "traditionally pronounce v-, d- and gi- all like y-", region: "Southern", truePrefix: "y")
        
        if baseWord.initial == "y" // corollary of v -> y / HomophonePrefixSet(prefixSet: ["gi", "d", "v"],
        {
            var createdVariant = baseWord
            createdVariant.initial = "v"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "v-/d-/gi- is traditionally pronounced as y- in most of Vietnam", region: "Western; Southern, Central", variantType: .fromPronunciationToActualSpelling)))
            
            var createdVariantTwo = baseWord
            createdVariantTwo.initial = "d"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariantTwo, variationReason: VariationReason(reason: "v-/d-/gi- is traditionally pronounced as y- in most of Vietnam", region: "Western; Southern, Central", variantType: .fromPronunciationToActualSpelling)))
            
            if (baseWord.cleanCore != "i" && !baseWord.cleanCore.hasPrefix("i"))
            {
                var createdVariantFour = baseWord
                createdVariantFour.initial = "gi"
                generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariantFour, variationReason: VariationReason(reason: "v-/d-/gi- is traditionally pronounced as y- in most of Vietnam", region: "Western; Southern, Central", variantType: .fromPronunciationToActualSpelling)))
            }
            
            var createdVariantThree = baseWord
            createdVariantThree.initial = "v"
            if (createdVariantThree.cleanCore.hasPrefix("i"))
            {
                createdVariantThree.cleanCore = String(createdVariantThree.cleanCore.dropFirst())
            }
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariantThree, variationReason: VariationReason(reason: "v-/d-/gi- is traditionally pronounced as y- in most of Vietnam", region: "Western; Southern, Central", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.cleanCore == "ê" && baseWord.final == "nh"
        {
            var createdVariant = baseWord
            createdVariant.cleanCore = "i"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "bẹnh -> bịnh", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if baseWord.cleanCore == "i" && baseWord.final == "n"
        {
            if baseWord.initial != "s" // "sin" doesn't exist a a syllable
                && baseWord.initial != "p" // pin doesn't get pronounced with a short vowel
            {
                var createdVariant = baseWord
                createdVariant.final = "nh"
                generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "tend to pronounce -in as -inh (that is, they shorten the vowel)", region: "Western; Southern; Central Vietnamese", variantType: .fromSpellingToRealPronunciation)))
            }
        } // TODO: need corollary
        else if baseWord.final == "n"
        {
            // bên/bến don't get -ng sounds
            if !(baseWord.initial == "b" && baseWord.cleanCore == "ê")
            {
                 StackResults(results: &generatedVariants, originalTerm: baseVariant, operatingWord: baseWord) { baseWord in
                    var newVariant = baseWord
                    newVariant.final = "ng"
                    return (newVariant, VariationReason(reason: "tend to pronounce -n endings as -ng, except after i vowels (for example ăn sounds like ăng)", region: "Western; Southern; Central Vietnamese", variantType: .fromSpellingToRealPronunciation))
                }
            }
        }
               
        if baseWord.cleanCore == "i" && baseWord.final == "nh" // corollary of above
        {
            if baseWord.initial != "s" && baseWord.initial != "b" // "sin" doesn't exist a a syllable, bin doesn't undergo the vowel shortening
            {
                var createdVariant = baseWord
                createdVariant.final = "n"
                generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "tend to pronounce -in as -inh (that is, they shorten the vowel)", region: "Western; Southern; Central Vietnamese", variantType: .fromPronunciationToActualSpelling)))
            }
            
            var createdVariant = baseWord
            createdVariant.cleanCore = "ê"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "bệnh -> bịnh", region: "Western; Southern; Central Vietnamese", variantType: .fromPronunciationToActualSpelling)))
        }
        else if baseWord.final == "ng"
        {
            // bên/bến don't get -ng sounds
            if !(baseWord.initial == "b" && baseWord.cleanCore == "ê")
            {
                var createdVariant = baseWord
                createdVariant.final = "n"
                generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "tend to pronounce -n endings as -ng, except after i vowels (for example ăn sounds like ăng)", region: "Western; Southern; Central Vietnamese", variantType: .fromPronunciationToActualSpelling)))
            } // TODO: need corollary
        }
        
        if baseWord.final.isEmpty// && (baseWord.cleanCore == "ưu" || baseWord.cleanCore == "ươu")
        {
            generatedVariants += HomophoneCoreSet(coreSet: ["u", "ưu", "ươu"], baseVariant: baseVariant, operatingWord: baseWord, reason: "traditionally pronounce -u, -ưu, and -ươu the same way, as -u, this is less common amongst younger speakers who will pronounce ưu and ươu closer to a northern 'iêu'", region: "Western; Southern")
            
            /*var createdVariant = baseWord
            createdVariant.cleanCore = "u"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "pronounce u, ưu, and ươu the same way", region: "Western; Southern", variantType: .homophones)))*/
        }
        
        if baseWord.toneIndex == VariantGenerator.TONEINDEX_NGA
        {
            var createdVariant = baseWord
            createdVariant.toneIndex = VariantGenerator.TONEINDEX_HOI
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "have merged dấu ngã (~) into dấu hỏi (?)", region: "Western; Southern; Central Vietnamese", variantType: .homophones)))
        }
        
        if baseWord.toneIndex == VariantGenerator.TONEINDEX_HOI // COROLLARY of above
        {
            var createdVariant = baseWord
            createdVariant.toneIndex = VariantGenerator.TONEINDEX_NGA
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "have merged dấu ngã (~) into dấu hỏi (?)", region: "Western; Southern; Central Vietnamese", variantType: .homophones)))
        }
               
        if baseWord.final == "t" && baseWord.cleanCore == "ô"
        {
            var createdVariant = baseWord
            createdVariant.final = "p"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "the -t final becomes -p after a ô vowel", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if baseWord.final == "p" && baseWord.cleanCore == "ô" // corollary of above
        {
            var createdVariant = baseWord
            createdVariant.final = "t"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "the -t final becomes -p after a ô vowel", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.cleanCore == "au" && baseWord.final.isEmpty
        {
            var createdVariant = baseWord
            createdVariant.cleanCore = "ao"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "-au sounds like -ao, for example: rau sounds like rao", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if baseWord.cleanCore == "ao" && baseWord.final.isEmpty // corollary of above
        {
            var createdVariant = baseWord
            createdVariant.cleanCore = "au"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "-au sounds like -ao, for example: rau sounds like rao", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.initial != "m"
        {
            if baseWord.cleanCore == "o" || baseWord.cleanCore == "ô" || baseWord.cleanCore == "ơ"
            {
                if !baseWord.final.isEmpty
                {
                    generatedVariants += HomophoneCoreSet(coreSet: ["o", "ô", "ơ"], baseVariant: baseVariant, operatingWord: baseWord, reason: "o, and ô (and less often ơ) all have their sounds merge in natural speech - what they merge to, honestly depends on the word", region: "Southern")
                }
            }
        }
        
        if (baseWord.final == "c" || baseWord.final == "t") && baseWord.cleanCore == "u"
        {
            var createdVariant = baseWord
            createdVariant.final = "p"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "the -c/-t final becomes -p after a u vowel", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if baseWord.final == "p" && baseWord.cleanCore == "u" // corollary of above
        {
            var createdVariant = baseWord
            createdVariant.final = "c"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "the -c/-t final is pronounced like -p after a u vowel", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
            
            var createdVariantSecond = baseWord
            createdVariantSecond.final = "t"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariantSecond, variationReason: VariationReason(reason: "the -c/-t final is pronounced like -p after a u vowel", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.cleanCore == "ê" && (baseWord.final == "t" || baseWord.final == "n" || baseWord.final == "ch" || baseWord.final == "nh")
        {
            // TODO: needs corollary
            var newVariant = baseWord
            newVariant.cleanCore = "ơ"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "in a traditional southern accent, ê rarely sounds like the modern (northern) one; ê followed by -t, -ch -n and -nh sounds like (usually) ơ or i", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
        }
        else if baseWord.cleanCore == "ê" && baseWord.final.isEmpty
        {
            // TODO: needs collary
            StackResults(results: &generatedVariants, originalTerm: baseVariant, operatingWord: baseWord) { baseWord in
                var newVariant = baseWord
                newVariant.cleanCore = "ơi"
                
                return (newVariant, VariationReason(reason: "in a traditional southern accent, ê rarely sounds like the modern (northern) one; many speakers - especially older, non-Saigon and diaspora - pronounce ê as ơi when there is no final consonant", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation))
            }
        }
        
        if baseWord.cleanCore == "iê" && baseWord.final == "m"
        {
            let variationReason = VariationReason(reason: "-iêm sounds like -im", region: "Western; Southern", variantType: .homophones)
            
            generatedVariants.append(VariantShuffleCore(newCore: "i", baseVariant: baseVariant, operatingWord: baseWord, variationReason: variationReason))
        } // TODO: needs corollary
        
        if baseWord.cleanCore == "ay"
        {
            var newVariant = baseWord
            newVariant.cleanCore = "ai"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "-ay sounds like -ai amongst many speakers, so words like máy sound like mái", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
        } // TODO: needs corollary
        
        if baseWord.cleanCore == "uê"
        {
            generatedVariants.append(VariantShuffleCore(newCore: "ươ", baseVariant: baseVariant, operatingWord: baseWord, variationReason: VariationReason(reason: "[write me], also is this limited to -n ending words? quên -> quơn", region: "Western; Southern", variantType: .homophones)))
        } // TODO: needs corollary
        
        if baseWord.cleanCore.hasPrefix("oa")
        {
            var newVariant = baseWord
            newVariant.cleanCore = newVariant.cleanCore.replacingOccurrences(of: "oa", with: "o")
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "oa -> a or oa -> o when the speaker's accent doesn't have labialisation - it depends on the word/speaker; xoài -> xòi or xài; loan -> lon", region: "Western; Southern; Central", variantType: .homophones))) // aer these homophones?
            
            var newVariantTwo = baseWord
            newVariantTwo.cleanCore = newVariantTwo.cleanCore.replacingOccurrences(of: "oa", with: "a")
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariantTwo, variationReason: VariationReason(reason: "oa -> a or oa -> o when the speaker's accent doesn't have labialisation - it depends on the word/speaker; xoài -> xòi or xài; loan -> lon", region: "Western; Southern; Central", variantType: .homophones))) // aer these homophones?
        } // TODO: needs corollary
        
        if baseWord.cleanCore == "uyê"
        {
            generatedVariants.append(VariantShuffleCore(newCore: "iê", baseVariant: baseVariant, operatingWord: baseWord, variationReason: VariationReason(reason: "a lot of southern accents don't have 'labialisation', so open lipped sounds like uyê get simplified. Nói chuyện -> nói chiện", region: "Western; Southern", variantType: .homophones)))
        } // TODO: needs corollary
        
        if baseWord.cleanCore == "uâ"
        {
            // generatedVariants.append(VariantShuffleCore(newCore: "ư", baseVariant: baseVariant, operatingWord: baseWord, variationReason: ))
            
             StackResults(results: &generatedVariants, originalTerm: baseVariant, operatingWord: baseWord) { baseWord in
                var newVariant = baseWord
                newVariant.cleanCore = "ư"
                return (newVariant, VariationReason(reason: "a lot of southern accents don't have 'labialisation', so open lipped sounds like uyê get simplified. luật -> lựt (but also -t's become -c's) -> so ultimately lực", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation))
            }
            
            /*// todo: if we add stacking, get rid of this
            if baseWord.final == "n"
            {
                var newVariant = baseWord
                newVariant.cleanCore = "ư"
                newVariant.final = "ng"
                generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "the above variation can stack with the -n -> -ng variation; infact lots of these variations can stack!", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
            }*/
        } // TODO: needs corollary
        
        if baseWord.initial == "s"
        {
            let variationReason = VariationReason(reason: "some southerners pronounce s- as a distinct consonant, that sounds sorttaaa like sh-", region: "Southern", variantType: .fromSpellingToRealPronunciation)
            generatedVariants.append(VariantShufflePrefix(newPrefix: "sh", baseVariant: baseVariant, operatingWord: baseWord, variationReason: variationReason))
        } // TODO: needs corollary
        
        if baseWord.cleanCore == "i" && baseWord.final == "nh" && !baseWord.initial.isEmpty
        {
            generatedVariants.append(VariantShuffleCore(newCore: "a", baseVariant: baseVariant, operatingWord: baseWord, variationReason: VariationReason(reason: "most westerners and some southerners will pronounce some instances of -inh as -anh, so sinh (born) == sanh, tính (personality) == tánh; these changes are often reflected in spelling", region: "Western; Southern", variantType: .spellingVariation)))
        }
        
        if baseWord.cleanCore == "a" && baseWord.final == "nh" && !baseWord.initial.isEmpty
        {
            generatedVariants.append(VariantShuffleCore(newCore: "i", baseVariant: baseVariant, operatingWord: baseWord, variationReason: VariationReason(reason: "most westerners and some southerners will pronounce some instances of -inh as -anh, so sinh (born) == sanh, tính (personality) == tánh; these changes are often reflected in spelling", region: "Western; Southern", variantType: .spellingVariation)))
        }
        
        if baseWord.cleanCore == "ai" && baseWord.final.isEmpty
        {
            generatedVariants.append(VariantShuffleCore(newCore: "ơi", baseVariant: baseVariant, operatingWord: baseWord, variationReason: VariationReason(reason: "some speakers pronounce as ơi, ngày mai -> ngày mơi, lại -> lợi - this accent shift happens more as you get further from Sài Gòn in the greater south and west of Vietnam ", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if baseWord.cleanCore == "ơi" && baseWord.final.isEmpty // corollary of abover
        {
            generatedVariants.append(VariantShuffleCore(newCore: "ai", baseVariant: baseVariant, operatingWord: baseWord, variationReason: VariationReason(reason: "some speakers pronounce as ơi, ngày mai -> ngày mơi, lại -> lợi - this accent shift happens more as you get further from Sài Gòn in the greater south and west of Vietnam ", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
        } // TODO: needs corollary
        
        if baseWord.cleanCore == "ươi" && baseWord.final.isEmpty
        {
            generatedVariants.append(VariantShuffleCore(newCore: "ư", baseVariant: baseVariant, operatingWord: baseWord, variationReason: VariationReason(reason: "outside of Saigon, it is common to hear words like người -> ngừ, rưởi -> rử", region: "Southern", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if baseWord.cleanCore == "ư" && baseWord.final.isEmpty // corollary of above
        {
            generatedVariants.append(VariantShuffleCore(newCore: "ươi", baseVariant: baseVariant, operatingWord: baseWord, variationReason: VariationReason(reason: "outside of Saigon, it is common to hear words like người -> ngừ, rưởi -> rử", region: "Southern", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.cleanCore == "â" && baseWord.final == "t"
        {
            var newVariant = baseWord
            newVariant.cleanCore = "ư"
            newVariant.final = "c"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "â and ê are both rare sounds in southern Vietnamese, -t is rarely pronounced as -t in southern Vietnamese; nhất sounds like nhứcs", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
        } // TODO: needs corollary
        
        if baseWord.final == "ch"
        {
            var newVariant = baseWord
            if newVariant.cleanCore == "a"
            {
                newVariant.cleanCore = "ă"
            }
            newVariant.final = "t"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "-ch endings are pronounced as -t in southern Viet (-c in northern Viet), and this ending also shortens the vowel (except ê becomes ơ)", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
            
            if (baseWord.cleanCore == "ê")
            {
                var newVariantTwo = baseWord
                newVariantTwo.cleanCore = "ơ"
                newVariantTwo.final = "t"
                generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariantTwo, variationReason: VariationReason(reason: "-ch endings are pronounced as -t in southern Viet (-c in northern Viet), and this ending also shortens the vowel (except ê becomes ơ) [lệch sounds like lợt]", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
            }
        } // TODO: needs corollary
        
        if baseWord.initial == "r"
        {
            var newVariant = baseWord
            newVariant.initial = "y"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "some speakers pronounce r- as a y- sound, so ra sounds like ya", region: "Southern", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if baseWord.initial == "y" // corollary of above
        {
            var newVariant = baseWord
            newVariant.initial = "r"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "some speakers pronounce r- as a y- sound, so rồi sounds like yồi", region: "Southern", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.initial == "r"
        {
            var newVariant = baseWord
            newVariant.initial = "g"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "some speakers pronounce r- as a g-/gh- sound, so ra sounds like ga, rồi sounds like gồi", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if baseWord.initial == "g" // corollary of above
        {
            var newVariant = baseWord
            newVariant.initial = "r"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "some speakers pronounce r- as a g-/gh- sound, so ra sounds like ga, rồi sounds like gồi", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.cleanCore == "ưi"
        {
            var newVariant = baseWord
            newVariant.cleanCore = "ơi"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "gửi (send) is usually pronounced, and sometimes spelt like gởi", region: "Western; Southern", variantType: .spellingVariation)))
        } // TODO: need corollary
        
        if baseWord.cleanCore == "ôi"
        {
             StackResults(results: &generatedVariants, originalTerm: baseVariant, operatingWord: baseWord) { baseWord in
                var newVariant = baseWord
                newVariant.cleanCore = "ui"
                return (newVariant, VariationReason(reason: "depending on the word, and mood (so it's not consistent) - -ôi is often pronounced as -ui (thôi -> thui for fun, but tôi -> tui *always*)", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation))
            }
        } // TODO: needs corollary
        
        // ---------- hanoi ------------
        
        if baseWord.final.isEmpty && (baseWord.cleanCore == "ưu" || baseWord.cleanCore == "ươu")
        {
            generatedVariants += HomophoneCoreSet(coreSet: ["iêu", "ưu", "ươu"], baseVariant: baseVariant, operatingWord: baseWord, reason: "pronounce iêu, ưu, and ươu similarly/the same", region: "Northern")
        }
        
        if baseWord.initial == "n"
        {
            var createdVariant = baseWord
            createdVariant.initial = "l"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "some speakers swap l and n initial consonant sounds", region: "Northern; An Giang", variantType: .fromSpellingToRealPronunciation)))
            // TODO: verify an giang thing, or is that just l -> n?
        }
        
        if baseWord.initial == "l" // corollary of above
        {
            var createdVariant = baseWord
            createdVariant.initial = "n"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "some speakers swap l and n initial consonant sounds", region: "Northern; An Giang", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if baseWord.final == "ng"
        {
            var createdVariant = baseWord
            createdVariant.final = "nh"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "pronounce -nh endings almost like -ng, but more nasally (cf. southern and northern pronunciations of the word 'Anh')", region: "Northern", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.final == "nh" // corollary of above
        {
            var createdVariant = baseWord
            createdVariant.final = "ng"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: VariationReason(reason: "pronounce -nh endings almost like -ng, but more nasally (cf. southern and northern pronunciations of the word 'Anh')", region: "Northern", variantType: .fromSpellingToRealPronunciation)))
        }
        
        generatedVariants += HomophonePrefixSet(prefixSet: ["gi", "d", "r"], baseVariant: baseVariant, operatingWord: baseWord, reason: "pronounce gi-, d- and r- the same way (like z-)", region: "Northern", truePrefix: "z")
        
        generatedVariants += HomophoneCoreSet(coreSet: ["ay", "ây"], baseVariant: baseVariant, operatingWord: baseWord, reason: "most Northern, and some Southern speakers pronounce -au more closely to -âu, so giàu and dầu sound alike", region: "Southern; Northern")
        
        generatedVariants += HomophoneCoreSet(coreSet: ["au", "âu"], baseVariant: baseVariant, operatingWord: baseWord, reason: "most Northern, and some Southern speakers pronounce -au more closely to -âu, so giàu and dầu sound alike", region: "Southern; Northern")
        
        if baseWord.initial == "v"
        {
            var newVariant = baseWord
            newVariant.initial = "z"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "in net speak (more commonly amongst northerners who love their z- sounds), v- is replaced by z-", region: "Northern; Internet", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if baseWord.initial == "z" // corollary of above
        {
            var newVariant = baseWord
            newVariant.initial = "v"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "in net speak (more commonly amongst northerners who love their z- sounds), v- is replaced by z-", region: "Northern; Internet", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.final == "ch"
        {
            var newVariant = baseWord
            
            if newVariant.cleanCore == "a"
            {
                newVariant.cleanCore = "ă"
            }
            
            newVariant.final = "c"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "-ch endings are pronounced as -c (-k) in northern Vietnamese, and the vowel is pronounced shorter", region: "Northern", variantType: .fromSpellingToRealPronunciation)))
            
            // not sure if this applies:
            /*if (baseWord.cleanCore == "ê")
            {
                var newVariantTwo = baseWord
                newVariantTwo.cleanCore = "ơ"
                newVariantTwo.final = "t"
                generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariantTwo, variationReason: VariationReason(reason: "-ch endings are pronounced as -t in southern Viet (-c in northern Viet), and this ending also shortens the vowel (except ê becomes ơ) [lệch sounds like lợt]", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
            }*/
        } // TODO: needs corollary
        
        // ---------- west ------------
        
        if baseWord.initial == "kh"
        {
            generatedVariants.append(VariantShufflePrefix(newPrefix: "ph", baseVariant: baseVariant, operatingWord: baseWord, variationReason: VariationReason(reason: "kh- is pronounced like ph- by some speakers; so khuya sounds like phia; khoẻ sounds like phẻ", region: "Western", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if baseWord.initial == "ph" // corollary of above
        {
            generatedVariants.append(VariantShufflePrefix(newPrefix: "kh", baseVariant: baseVariant, operatingWord: baseWord, variationReason: VariationReason(reason: "kh- is pronounced like ph- by some speakers; so khuya sounds like phia; khoẻ sounds like phẻ", region: "Western", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.cleanCore == "ây" && baseWord.final.isEmpty
        {
            generatedVariants.append(VariantShuffleCore(newCore: "i", baseVariant: baseVariant, operatingWord: baseWord, variationReason: VariationReason(reason: "some speakers, in a small number words (with no ending consonants!) will pronounce -ây like -i, so bây giờ sounds like bi giờ", region: "Western; Southern", variantType: .fromSpellingToRealPronunciation)))
        } // needs corollary
        
        if baseWord.cleanCore == "i" && baseWord.final.isEmpty // corollary of above
        {
            generatedVariants.append(VariantShuffleCore(newCore: "ây", baseVariant: baseVariant, operatingWord: baseWord, variationReason: VariationReason(reason: "some speakers, in a small number of words (with no ending consonants!) will pronounce -ây like -i, so bây giờ sounds like bi giờ", region: "Western; Southern", variantType: .fromPronunciationToActualSpelling)))
        }
        
        if baseWord.initial == "ph" && baseWord.cleanCore == "a"
        {
            generatedVariants.append(VariantShufflePrefix(newPrefix: "pp", baseVariant: baseVariant, operatingWord: baseWord, variationReason: VariationReason(reason: "some speakers pronounce ph- like the p in 'patrick', so phạt sounds like 'pạc' but the p is aspirated", region: "Western", variantType: .fromSpellingToRealPronunciation)))
        } // TODO: needs corollary, this is a hard one
        
        // ---------- everyone ------------
        
        if baseWord.initial == "tr"
        {           
             StackResults(results: &generatedVariants, originalTerm: baseVariant, operatingWord: baseWord) { baseWord in
                var newVariant = baseWord
                newVariant.initial = "ch"
                return (newVariant, VariationReason(reason: "tr- collapses to ch-", region: "Western; Northern", variantType: .fromSpellingToRealPronunciation))
            }
            
            let variationReasonTwo = VariationReason(reason: "LESS COMMON: tr- is pronounced as gi-, but spelt like z- for fun; Northern Vietnam doesn't traditionally pronounce tr-, and you'll notice a lot of people say tr as z- in set phrases đẹp zai, ôi zời ơi)", region: "Northern", variantType: .homophones)
            generatedVariants.append(VariantShufflePrefix(newPrefix: "gi", baseVariant: baseVariant, operatingWord: baseWord, variationReason: variationReasonTwo))
        }
        
        if baseWord.initial == "ch" // corollary of above
        {
            let variationReason = VariationReason(reason: "tr- collapses to ch- almost always in Western and Northern accents, and some speakers of other regions do it too", region: "Western; Northern", variantType: .fromPronunciationToActualSpelling)
            generatedVariants.append(VariantShufflePrefix(newPrefix: "tr", baseVariant: baseVariant, operatingWord: baseWord, variationReason: variationReason))
            
            let variationReasonTwo = VariationReason(reason: "LESS COMMON: tr- is pronounced as gi-, but spelt like z- for fun; Northern Vietnam doesn't traditionally pronounce tr-, and you'll notice a lot of people say tr as z- in set phrases đẹp zai, ôi zời ơi)", region: "Northern", variantType: .homophones)
            generatedVariants.append(VariantShufflePrefix(newPrefix: "gi", baseVariant: baseVariant, operatingWord: baseWord, variationReason: variationReasonTwo))
        }
        
        if baseWord.initial == "z" // corollary of some of above
        {
            let variationReasonTwo = VariationReason(reason: "LESS COMMON: tr- is pronounced as gi- (and sometimes spelt like gi- too), or spelt like z- for fun; Northern Vietnam doesn't traditionally pronounce tr-, and only has gi- and ch- and you'll notice a lot of people say tr as z- in set phrases đẹp zai, ôi zời ơi)", region: "Northern", variantType: .fromPronunciationToActualSpelling)
            generatedVariants.append(VariantShufflePrefix(newPrefix: "tr", baseVariant: baseVariant, operatingWord: baseWord, variationReason: variationReasonTwo))
        }
        
        if baseWord.initial == "p"
        {
            let variationReason = VariationReason(reason: "all p- (not ph!) words are loanwords, and this sound doesn't exist in the Vietnamese language", region: "Everyone", variantType: .homophones)
            
            generatedVariants.append(VariantShufflePrefix(newPrefix: "b", baseVariant: baseVariant, operatingWord: baseWord, variationReason: variationReason))
        }
        
        if baseWord.initial == "b" // corollary of above
        {
            let variationReason = VariationReason(reason: "all p- (not ph!) words are loanwords, and this sound doesn't exist in the Vietnamese language", region: "Everyone", variantType: .fromPronunciationToActualSpelling)
            generatedVariants.append(VariantShufflePrefix(newPrefix: "p", baseVariant: baseVariant, operatingWord: baseWord, variationReason: variationReason))
        }
        
        if baseWord.initial == "s"
        {
            let variationReason = VariationReason(reason: "Northerners never pronounce s-, and always pronounce it as x-, and only some Southerners do", region: "Everyone", variantType: .homophones)
            generatedVariants.append(VariantShufflePrefix(newPrefix: "x", baseVariant: baseVariant, operatingWord: baseWord, variationReason: variationReason))
        }
        
        if baseWord.initial == "x" // corollary of above
        {
            if !(baseWord.cleanCore == "i" && baseWord.final == "n") // exclude "sin" as a possibility
            {
                let variationReason = VariationReason(reason: "Northerners never pronounce s-, and always pronounce it as x-, and only some Southerners do", region: "Everyone", variantType: .homophones)
                generatedVariants.append(VariantShufflePrefix(newPrefix: "s", baseVariant: baseVariant, operatingWord: baseWord, variationReason: variationReason))
            }
        }
        
        if baseWord.cleanCore == "i" && baseWord.final.isEmpty
        {
            var newVariant = baseWord
            newVariant.cleanCore = "y"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "whether for fun, or whatever, sometimes -i words are spelt -y, for example very occasionally you see shops selling bánh mỳ", region: "Everyone", variantType: .homophones))) // TODO: needs spelling variation
        }
        
        if baseWord.cleanCore == "y" && baseWord.final.isEmpty
        {
            var newVariant = baseWord
            newVariant.cleanCore = "i"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "whether for fun, or whatever, sometimes -i words are spelt -y, for example very occasionally you see shops selling bánh mỳ", region: "Everyone", variantType: .homophones))) // TODO: needs spelling variation
        }
        
        if baseWord.initial != "m" && (baseWord.cleanCore == "o" || baseWord.cleanCore == "ô") && baseWord.final == "c"
        {
             StackResults(results: &generatedVariants, originalTerm: baseVariant, operatingWord: baseWord) { baseWord in
                var newVariant = baseWord
                newVariant.final = "p"
                return (newVariant, VariationReason(reason: "the -c final is pronounced like a -p after a ô or o vowel, for some initial consonants (L, H)", region: "Everyone", variantType: .fromSpellingToRealPronunciation))
            }
        } // needs corollary
        
        // ---------- unknown ------------
        
        if baseWord.initial == "r"
        {
            var newVariant = baseWord
            newVariant.initial = "rr"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "some speakers pronounce r- as a trilled/rolled r-", region: "Unknown", variantType: .fromSpellingToRealPronunciation)))
        }
        
        if baseWord.initial == "rr"
        {
            var newVariant = baseWord
            newVariant.initial = "r"
            generatedVariants.append(PronunciationVariant(baseVariant: baseVariant, operatingWord: newVariant, variationReason: VariationReason(reason: "some speakers pronounce r- as a trilled/rolled r-", region: "Unknown", variantType: .fromPronunciationToActualSpelling)))
        }
        
        return generatedVariants
    }
    
    public static func HomophonePrefixSet(prefixSet: Array<String>, baseVariant: String, operatingWord: OperatingWord, reason: String, region: String, truePrefix: String = "") -> Array<PronunciationVariant>
    {
        var generatedVariants = Array<PronunciationVariant>()
        
        let variationReason = VariationReason(reason: reason, region: region, variantType: .homophones)
        
        for prefix in prefixSet
        {
            if operatingWord.initial == prefix
            {
                for prefixSub in prefixSet
                {
                    if (prefixSub != prefix)
                    {
                        // vịt -> giit....?
                        if !(prefixSub == "gi" && operatingWord.cleanCore == "i")
                        {
                            generatedVariants.append(VariantShufflePrefix(newPrefix: prefixSub, baseVariant: baseVariant, operatingWord: operatingWord, variationReason: variationReason))
                        }
                    }
                }
                
                if (!truePrefix.isEmpty)
                {
                    var variationReason2 = variationReason
                    variationReason2.variantType = .fromSpellingToRealPronunciation
                    generatedVariants.append(VariantShufflePrefix(newPrefix: truePrefix, baseVariant: baseVariant, operatingWord: operatingWord, variationReason: variationReason2))
                }
            }
            
            if !truePrefix.isEmpty, operatingWord.initial == truePrefix
            {
                var variationReason2 = variationReason
                variationReason2.variantType = .fromPronunciationToActualSpelling
                generatedVariants.append(VariantShufflePrefix(newPrefix: prefix, baseVariant: baseVariant, operatingWord: operatingWord, variationReason: variationReason2))
            }
        }
        
        return generatedVariants
    }
    
    
    public static func VariantShufflePrefix(newPrefix: String, baseVariant: String, operatingWord: OperatingWord, variationReason: VariationReason) -> PronunciationVariant
    {
        var createdVariant = operatingWord
        createdVariant.initial = newPrefix
        
        // EXCEPTIONS!!!
        if newPrefix == "gi" && createdVariant.cleanCore.hasPrefix("i") && createdVariant.cleanCore.count > 1
        {
            createdVariant.cleanCore = String(createdVariant.cleanCore.dropFirst())
        }
        else if newPrefix == "gi" && createdVariant.cleanCore == "i"
        {
            createdVariant.cleanCore = "shouldn't have gotten here, something's gone wrong"
        }
        
        return PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: variationReason)
    }
    
    public static func HomophoneCoreSet(coreSet: Array<String>, baseVariant: String, operatingWord: OperatingWord, reason: String, region: String) -> Array<PronunciationVariant>
    {
        var generatedVariants = Array<PronunciationVariant>()
        
        for core in coreSet
        {
            if operatingWord.cleanCore == core
            {
                let variationReason = VariationReason(reason: reason, region: region, variantType: .homophones)
                
                for coreSub in coreSet
                {
                    if (coreSub != core)
                    {
                        generatedVariants.append(VariantShuffleCore(newCore: coreSub, baseVariant: baseVariant, operatingWord: operatingWord, variationReason: variationReason))
                    }
                }
            }
        }
        
        return generatedVariants
    }
    public static func VariantShuffleCore(newCore: String, baseVariant: String, operatingWord: OperatingWord, variationReason: VariationReason) -> PronunciationVariant
    {
        var createdVariant = operatingWord
        createdVariant.cleanCore = newCore
        return PronunciationVariant(baseVariant: baseVariant, operatingWord: createdVariant, variationReason: variationReason)
    }
    
    
    fileprivate class BasicRegexWrapper
    {
        let regex: NSRegularExpression
        
        init(pattern: String)
        {
            regex = try! NSRegularExpression(pattern: pattern)
        }
        
        func getMatchesInString(input: String) -> Array<String>
        {
            var results = Array<String>()
            
            let range = NSRange(input.startIndex..., in: input)
            // let results = regex.matches(in: input,
            //                            range: range)
            
            if let match = regex.firstMatch(in: input, options: [], range:range) {
                for i in 0 ..< match.numberOfRanges
                {
                    if let thisRange = Range(match.range(at: i), in: input) {
                        let subRange = input[thisRange]
                        results.append(String(subRange))
                    }
                }
                
            }
            
            return results
        }
        
    }
    
}

