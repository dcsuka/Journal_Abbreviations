# Comprehensive Journal Abbreviations Database

## Project Overview

This project combines journal abbreviation information from the [PubMed NLM Journal Repository](https://www.ncbi.nlm.nih.gov/nlmcatalog) as well as from Endnote. It makes citing articles easier by increasing the likelihood that journals you cite will already have abbreviations available with no manual effort.

Almost ***60,000*** entries are included, including some punctuation-based journal name variants to increase match likelihood. The EndNote match system is case-insensitive, so no variants are necessary in that regard.

R Markdown code for the project is available in `JournalAbbreviations.pdf`.

## Installation Procedures

If a certain journal is not included, it is always possible to manually add it. The `.txt` files are tab-delimited  as a requirement for EndNote.

- For the combined terms file, download and import `Combined_Terms.txt`.
- If you already have the basic EndNote terms installed, you can download and import `Just_PubMed.txt` for the PubMed abbreviations alone. These will not contain the aforementioned punctuation-based variants, however.
- The raw PubMed data pivoted into `.csv` format is available in `Just_PubMed_Raw.csv`.

Once you have downloaded the file of your choice, you can install into EndNote via clicking **Library** &rarr; **Open Term List** &rarr; **Journals Term List** &rarr; **Lists** &rarr; **Import List**.

## Contributions

I would be happy to accomodate further data if available, or potentially expand this infrastructure to other citation mangement systems such as LaTeX, Zotero, and Mendeley. Feel free to get in touch!
