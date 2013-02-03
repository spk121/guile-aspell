/*
  Copyright 2009, 2013 Michael L Gran

  This file is part of guile-aspell.

  guile-aspell is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  guile-aspell is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with guile-aspell.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef GU_ASPELL_H
#define GU_ASPELL_H


#if BUILDING_GUILE_ASPELL && HAVE_VISIBILITY
#define API __attribute__((__visibility__("default")))
#elif BUILDING_GUILE_ASPELL && defined _MSC_VER
#define API __declspec(dllexport)
#elif defined _MSC_VER
#define API __declspec(dllimport)
#else
#define API
#endif

void gu_aspell_init (void)  API;
SCM gu_is_speller_p (SCM x) API;
SCM gu_aspell_new_speller (void) API;
SCM gu_aspell_set_lang (SCM lang) API;
SCM gu_aspell_word (SCM word, SCM speller) API;
SCM gu_aspell_correct_p (SCM word, SCM speller) API;
SCM gu_aspell_add_word (SCM word, SCM speller) API;
SCM gu_aspell_store_replacement (SCM misspelled, SCM correct, SCM speller) API;

#endif
