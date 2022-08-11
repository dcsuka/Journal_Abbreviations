library(tidyverse)
library(tokenizers)

journals <- read_delim("https://ftp.ncbi.nih.gov/pubmed/J_Medline.txt",
                       delim = "\\n", col_names = "Information")

journal_abbreviations <- journals %>%
  filter(str_detect(Information, "[:alnum:]")) %>%
  separate(Information, into = c("field", "info"), sep = ":\\s?",
           extra = "merge") %>%
  mutate(id = cumsum(field == "JrId")) %>%
  pivot_wider(names_from = field, values_from = info) %>%
  select(-id, -JrId, -IsoAbbr) #IsoAbbr is always equal to MedAbbr


mutate(JournalTitle = str_replace_all(str_to_title(JournalTitle),
                                      c(" Of " = " of ",
                                        " And " = " and ",
                                        " An " = " an ",
                                        " A " = " a ",
                                        " The " = " the ",
                                        " Et " = " et ",
                                        " De " = " de ",
                                        " Y " = " y ",
                                        " In " = " in ")))

jab <- journal_abbreviations %>%
  mutate(split_journal_title = tokenize_words(JournalTitle),
         split_medabbr = tokenize_words(MedAbbr),
         split_medabbrs = paste(map2_chr(split_medabbr, split_journal_title, 
         function(x, y) {
           if_else(x %in% y, x, paste0(x, "."))
         }), collapse = " "))

jab <- journal_abbreviations %>%
  mutate(split_journal_title = tokenize_words(JournalTitle),
         split_medabbr = tokenize_words(MedAbbr)) %>%
  rowwise() %>%
  mutate(Abbreviation_1 = map_chr(split_medabbr, ~if_else(. %in% split_journal_title, ., paste0(., "."))) %>%
                                  paste(collapse = " ") %>%
                                  str_to_title()) %>%
  ungroup() %>%
  select(JournalTitle, Abbreviation_1, MedAbbr) %>%
  rename(Journal_Name = JournalTitle,
         Abbreviation_2 = MedAbbr)




map(list.files("Endnote_Journal_Files", full.names = TRUE),
                                      ~read_tsv(., col_names = c("Journal_Name", "Abbr1", "Abbr2")) %>%
                                      select(!starts_with("X"))) %>%
  bind_rows()



view(jab)






