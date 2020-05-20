# Bookends Tools

[Bookends](http://www.sonnysoftware.com/) is an excellent bibliographic/research manager for macOS. This Alfred workflow curates 11 tools together in one interface to integrate between Bookends and other apps. You can use Alfred keywords (*be…*) and/or your preferred key binding to trigger them (edit the Hotkey trigger). The workflow is designed for Alfred 3, and should keep itself up-to-date using [OneUpdater](https://github.com/vitorgalvao/alfred-workflows/tree/master/OneUpdater).

[**Download it here…**](https://raw.githubusercontent.com/iandol/bookends-tools/master/bookends-tools.alfredworkflow)

![Workflow screenshot](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/workflow.png)

Note: the tools denoted by 📄 use Applescript `System Events` to trigger keyboard bindings with delays; the delays work fine for me but may need to be adjusted for you. If the tools seems to not work try to manually type ⌘V and enter.

**key**: `📄: select some text in another app then trigger tool` — `🗄: select reference(s) within Bookends then trigger tool` — `⌨: trigger tool and enter some text`  

1. **`beidsearch`** 📄 — Find a selected uniqueID in Bookends. For example, if you have a temporary citation like {Koffka, 1922, #6475} in your word-processor, double-click select the Bookends ID `6475`, then trigger this workflow and it will find the reference in Bookends for you.
2. **`bebrowser`** 📄 — Search selected text in Bookends browser. For the Pubmed interface you should select this manually in the bookends browser before triggering this tool. If the automatic paste into the search field fails, press ⌘V and ENTER to trigger the search.
3. **`berefsearch`** 📄 — Take selected text like "(Doe et al., 2005)" citation, clean it up to become "Doe 2005" and send it to Bookend's quick search. This is great because you can take a formatted ref in a text document and search for the first author/year, then quickly paste back (⌘Y for Scrivener) the Bookends style temporary citation in its place!
4. **`bequickadd`** 📄 — Take a selected `DOI` / `PMID` / `ISBN` / `JSTOR` in any application and send it to Bookend's Quick Add (added in Bookends 13.0.3+) to quickly add this reference to your database.
5. **`betobibtex`** ⌨ — You enter the name of a Bookends static/smart group name and this will create a BibTeX bibliography file for those particular groups. Very useful for Pandoc and/or LaTeX workflows. You can optionally generate JSON. You can configure the export path in the workflow variables (default Desktop/). ![betobibtex](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/betobibtex.png)
6. **`betoopml`** 🗄 — Select multiple references within Bookends, then run this to create an OPML file which you can import into Scrivener or other OPML-aware tool. This will contain the abstract and notes which is very useful for research. It contains links back to the Bookends reference. You can configure the export path in the workflow variables (default Desktop/).
7.  **`bescopus`** 🗄 — Select a reference with a DOI in Bookends, then trigger this to search Scopus with that DOI.  It will return an inline results list for the Scopus entry AND the Cited-by page if available. Select an entry to open that page. Environment variables: `appendScopusNotes` \[true/false\] — copy the URLs into the Notes field | `scopusKey` \[value\] if you have registered for your own key enter it here | `scopusBaseURL` \[url\] — If you got through a proxy, enter the URL base to replace https://www.scopus.com/. ![bescopus](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/bescopus.png)
8. **`becite`** ⌨ — Activate `becite` in any application to search your bookends database with one or more author/editor names and an optional year (for example: `friston hobson 2014`), and get a floating inline results list. You can then select a result and paste the selected ref as a **temporary citation** (⌘ pastes Pandoc style, ⌥ pastes MMD style, ⌃ pastes formatted ref, ⇧ opens ref in Bookends, \[fn\] opens attachment). For **becite**, **betitle**. and **beall** there is also a workflow environment variable (citeUsesRTF & commentText) to copy the Pandoc/MMD temporary citation using RTF; this puts the link back to bookends into an RTF comment (and/or annotation in Scrivener).  ![becite](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/becite.png)
9. **`betitle`** ⌨ — Enter one or more words contained in the title or keywords and an optional year, and get a floating inline results list. You can then paste this as a **temporary citation** (⌘ pastes Pandoc style, ⌥ pastes MMD style, ⌃ pastes formatted ref, ⇧ opens ref in Bookends, \[fn\] opens attachment).  ![betitle](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/betitle.png)
10. **`beall`** ⌨ — You enter one or more words contained in any field and an optional year, and get an inline results list. You can then paste this as a **temporary citation** (⌘ pastes Pandoc style, ⌥ pastes MMD style, ⌃ pastes formatted ref, ⇧ opens ref in Bookends, \[fn\] opens attachment).  
11. **`bebib`** ⌨ — You enter one or more author/editor names and an optional year, and get an inline results list.  You can then paste the selected ref as a **formatted reference** (see workflow variable `citationStyle`; ⌘ pastes Pandoc style, ⌥ pastes MMD style).

## Workflow variables

![variables](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/variables.png)  

There are several workflow variables which let you modify the functionality of the tools: 

* `tempCitationStyle` : for becite / betitle / beall the default temporary citation style is Bookends (with key modifiers allowing Pandoc and MMD formats). However if you will never use the Bookends format, you can set `tempCitationStyle` to `Pandoc` / `MMD` / `LaTeX` and the default temp citation will be set accordingly.
* `attachmentsFolder` : relative or absolute path to where your Bookends attachments are stored. This is used so that you can Quicklook results with PDF attachments from becite / betitle / beall tools (press [shift] or ⌘Y)
* `appendScopusNotes` (default = TRUE): allows you to toggle the behaviour whereby the Scopus URLs are appended back to the Bookends reference note stream. 
* `BibTeXtoJSON` (default = FALSE): allows you to convert the BIB file to a JSON file, which at least for Pandoc-citeproc is much faster (~3X) to then process for the bibliography. 
* `citeUsesRTF`  (default = FALSE) & `commentText`: for the `becite` and `betitle` tools for Pandoc/MMD temporary citations, if you enable this then the temp citation is copied as RTF with a comment-enclosed link back to Bookends. In Scrivener if you enable **Preferences▸Sharing▸Import comments as inline annotations**, then the comment becomes an inline annotation. `commentText` is the text that is linked back to Bookends (default is @).
* `protectBibTitles`  (default = FALSE): makes titles in the BIB file {{ wrapped }} so the case is not changed in subsequent processing.
* `citationStyle`  (default = APA 6th Edition): is the Bookends bibliographic style used by `bebib` when outputting the formatted reference.
* `exportPath`  (default = Desktop): used by `betoopml` and `betobibtex`
* `scopusKey`: your personal Scopus API key

### Scopus Info
For the Scopus search tool, ideally [you should register for your own Scopus API key](https://dev.elsevier.com/) (without it it will use the demo key which may or may not work) and enter it in the workflow variables. The Scopus URLs also benefit from an institutional subscription, otherwise you will see a Scopus preview (which still contains useful information). If your institution offers a proxy, then you can enter the `scopusBaseURL` variable to use that.

## Sources
Several of these very useful tools have been modified from the following sources:

### betoopml
Thanks to Dave Glogowski (dave83); [Bookends forum thread](https://www.sonnysoftware.com/phpBB3/viewtopic.php?f=6&t=3882)

### betobibtex
Thanks and MIT copyright to Naupaka Zimmerman; [Bookends forum thread](https://www.sonnysoftware.com/phpBB3/viewtopic.php?f=6&t=4246) | [Original Gist](https://gist.github.com/naupaka/3637da8f1449a279a79e643575a7c2e1)

### becite & bebib
Thanks to kseggleton for the original applescript version; [Bookends forum thread](https://www.sonnysoftware.com/phpBB3/viewtopic.php?f=6&t=4051)

### OneUpdater
Thanks to Vitor for his excellent update system for Alfred workflows: [OneUpdater](https://github.com/vitorgalvao/alfred-workflows/tree/master/OneUpdater)

