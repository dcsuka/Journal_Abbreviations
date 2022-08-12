#' ---
#' title: "Creating a Comprehensive Medical Journal Abbreviation List"
#' author: "David Csuka"
#' output: pdf_document
#' header-includes:
#' - \usepackage{setspace}
#' ---
#'\setlength{\parindent}{1cm}
#'\bigskip
#'The current medical journal abbreviation lists available for bibliography managers such as EndNote do not contain information from PubMed,
#'which is very important for the ease and convenience of academic citations. I created a comprehensive database from both the PubMed
#'terms as well as those already available in EndNote.
#'\bigskip
#+message=FALSE
library(tidyverse)
library(tokenizers)

pubmed_journals <- read_delim("https://ftp.ncbi.nih.gov/pubmed/J_Medline.txt",
                       delim = "\\n", col_names = "Information")

pubmed_journals
#'\bigskip
#+message=FALSE
journal_abbreviations <- pubmed_journals %>%
  filter(str_detect(Information, "[:alnum:]")) %>%
  separate(Information, into = c("field", "info"), sep = ":\\s?",
           extra = "merge") %>%
  mutate(id = cumsum(field == "JrId")) %>%
  pivot_wider(names_from = field, values_from = info) %>%
  select(-id, -JrId, -IsoAbbr) #IsoAbbr is always equal to MedAbbr

write_excel_csv(journal_abbreviations, "Just_PubMed_Raw.csv")

journal_abbreviations
#'\bigskip
#+message=FALSE
new_nlm_terms <- journal_abbreviations %>%
  mutate(split_journal_title = tokenize_words(JournalTitle),
         split_medabbr = tokenize_words(MedAbbr)) %>%
  rowwise() %>%
  mutate(Abbreviation_1 = map_chr(split_medabbr,
                                  ~if_else(. %in% split_journal_title,
                                           .,
                                           paste0(., "."))) %>%
                                  paste(collapse = " ") %>%
                                  str_to_title()) %>%
  ungroup() %>%
  select(JournalTitle, Abbreviation_1, MedAbbr) %>%
  rename(Journal_Name = JournalTitle,
         Abbreviation_2 = MedAbbr)

write_tsv(new_nlm_terms, "Just_PubMed.txt", col_names = FALSE)

new_nlm_terms
#'\bigskip
#+message=FALSE
old_endnote_terms <- map(list.files("Endnote_Journal_Files", full.names = TRUE),
                                      ~read_tsv(., col_names = c("Journal_Name",
                                                                 "Abbreviation_1",
                                                                 "Abbreviation_2")) %>%
                                      select(!starts_with("X")))

old_endnote_terms
#'\bigskip
#+message=FALSE
combined_terms <- bind_rows(new_nlm_terms, old_endnote_terms, .id = "id") %>%
  filter(!is.na(Abbreviation_1) & !is.na(Abbreviation_2) &
           Abbreviation_1 != "" & Abbreviation_2 != "")

combined_terms
#'\bigskip
#'Some of the journal names contain parentheses or brackets, and a version without them should be stored in the
#'journal names field so that the abbreviation can be utilized.
#'\bigskip
#+message=FALSE
without_punct <- filter(combined_terms, str_detect(Journal_Name,
                                                   "(\\(|\\[).*(\\)|\\])|[:punct:]")) %>%
  mutate(Journal_Name = if_else(str_remove_all(Journal_Name,
                                               "((\\(|\\[).*(\\)|\\]))|[:punct:]") == "",
                                str_remove_all(Journal_Name,
                                               "\\(|\\[|\\)|\\]|[:punct:]"),
                                str_remove_all(Journal_Name,
                                               "((\\(|\\[).*(\\)|\\]))|[:punct:]")) %>%
                        str_trim())

without_punct
#'\bigskip
#+message=FALSE
combined_terms <- bind_rows(without_punct, combined_terms) %>%
  arrange(Journal_Name, as.numeric(id)) %>%
  select(-id) %>%
  distinct(str_to_lower(Journal_Name), .keep_all = TRUE) %>%
  select(-`str_to_lower(Journal_Name)`)

write_tsv(combined_terms, "Combined_Terms.txt", col_names = FALSE)

combined_terms