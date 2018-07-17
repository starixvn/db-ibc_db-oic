USE [bodb_OIC]
GO

-- Remove AM Personal Emails
UPDATE dbo.UserLicenseeType
SET Email = 'lmd@enpine.com'
WHERE Email IN ('nick@zelianta.com', 'kai@zelianta.com');
GO;


-- Add more languages
INSERT INTO dbo.[Language](LanguageName)
VALUE ('Afrikaans'), ('Esperanto'), ('Maltese'), ('Sinhala'), ('Yoruba'), ('Albanian'), ('Estonian'), ('Irish'), ('Maori'), ('Slovak'), ('Zulu'), 
    ('Amharic'), ('Filipino'), ('Marathi'), ('Slovenian'), ('Arabic'), ('Finnish'), ('Mongolian'), ('Somali'), ('Armenian'), ('French'), ('Javanese'), ('Myanmar (Burmese)'),  
    ('Azerbaijani'), ('Frisian'), ('Kannada'), ('Nepali'), ('Sundanese'), ('Basque'), ('Galician'), ('Kazakh'), ('Norwegian'), ('Swahili'), 
    ('Belarusian'), ('Georgian'), ('Khmer'), ('Pashto'), ('Swedish'), ('Bengali'), ('Persian'), ('Tajik'), ('Bosnian'), ('Kurdish (Kurmanji)'), ('Tamil'), 
    ('Bulgarian'), ('Gujarati'), ('Kyrgyz'), ('Portuguese'), ('Telugu'), ('Catalan'), ('Haitian Creole'), ('Lao'), ('Punjabi'), ('Cebuano'), ('Hausa'), ('Latin'), ('Turkish'),
    ('Chichewa'), ('Hawaiian'), ('Latvian'), ('Ukrainian'), ('Hebrew'), ('Lithuanian'), ('Samoan'), ('Urdu'), ('Croatian'), ('Hindi'), ('Luxembourgish'), ('Scots Gaelic'), ('Uzbek'),
    ('Czech'), ('Hmong'), ('Macedonian'), ('Serbian'), ('Danish'), ('Malagasy'), ('Sesotho'), ('Welsh'), ('Dutch'), ('Icelandic'), ('Malay'), ('Shona'), ('Xhosa'), ('Icelandic'), ('Malayalam'), 
    ('Sindhi'), ('Yiddish');
GO;