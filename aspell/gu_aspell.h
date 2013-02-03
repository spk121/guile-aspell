#ifndef GU_ASPELL_H
#define GU_ASPELL_H

#ifdef DLL_EXPORT
#define API __attribute__ ((dllexport, cdecl))
#else
#define API
#endif

void gu_aspell_init (void) API;
SCM gu_is_speller_p (SCM x) API;
SCM gu_aspell_new_speller (void) API;
SCM gu_aspell_set_lang (SCM lang) API;
SCM gu_aspell_word (SCM word, SCM speller) API;
SCM gu_aspell_correct_p (SCM word, SCM speller) API;
SCM gu_aspell_add_word(SCM word, SCM speller) API;
SCM gu_aspell_store_replacement (SCM misspelled, SCM correct, SCM speller) API;


#endif
