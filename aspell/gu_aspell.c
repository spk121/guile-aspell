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

#define _GNU_SOURCE		/* for asprintf */
#include <config.h>
#include <aspell.h>
#include <assert.h>
#include <libguile.h>
#include <stdio.h>
#include <string.h>

#include "gu_aspell.h"
#define STREQ(a, b)     (strcmp (a, b) == 0)

static SCM equalp_speller (SCM x1, SCM x2);
static size_t free_speller (SCM x);
static SCM mark_speller (SCM x);
static int print_speller (SCM x, SCM port, scm_print_state * pstate);
static int _scm_is_speller (SCM x);
static SCM _scm_from_speller (AspellSpeller * x);
static AspellSpeller *_scm_to_speller (SCM x);
static void gu_aspell_cleanup (void);

static AspellConfig *spell_config;
static AspellSpeller *default_speller;
static scm_t_bits speller_tag;

SCM s_default_speller;

/* speller -- in C, a AspellSpeller *.  In Scheme, a smob that
   contains the pointer */

SCM
gu_aspell_new_speller ()
{
  AspellCanHaveError *possible_err = new_aspell_speller (spell_config);
  AspellSpeller *spell_checker = 0;
  if (aspell_error_number (possible_err) != 0)
    {
      scm_misc_error ("aspell-speller",
		      aspell_error_message (possible_err), SCM_BOOL_F);
    }
  else
    {
      spell_checker = to_aspell_speller (possible_err);
    }
  return _scm_from_speller (spell_checker);
}

int
_scm_is_speller (SCM x)
{
  if (SCM_SMOB_PREDICATE (speller_tag, x))
    {
      if (SCM_SMOB_DATA (x) != 0)
	return 1;
      else
	return 0;
    }
  else
    return 0;

}

AspellSpeller *
_scm_to_speller (SCM x)
{
  assert (_scm_is_speller (x));

  return (AspellSpeller *) SCM_SMOB_DATA (x);
}

SCM
_scm_from_speller (AspellSpeller * x)
{
  SCM s_spl;

  assert (x != NULL);

  SCM_NEWSMOB (s_spl, speller_tag, x);

  assert (x == (AspellSpeller *) SCM_SMOB_DATA (s_spl));

  if (0)
    {
      fprintf (stderr, "Making smob from speller at %p", (void *) x);
    }

  return (s_spl);
}

// Spellers are equal if they point to the same C structure
SCM
equalp_speller (SCM x1, SCM x2)
{
  AspellSpeller *spl1, *spl2;

  /* This assert can be thrown if either of the spellers has already
     been freed.  */
  assert (_scm_is_speller (x1));
  assert (_scm_is_speller (x2));

  spl1 = (AspellSpeller *) SCM_SMOB_DATA (x1);
  spl2 = (AspellSpeller *) SCM_SMOB_DATA (x2);

  if ((spl1 == NULL) || (spl2 == NULL))
    return SCM_BOOL_F;
  else if (spl1 != spl2)
    return SCM_BOOL_F;
  else
    return SCM_BOOL_T;
}

SCM
mark_speller (SCM x)
{
  // No SCMs in the speller type: nothing to do here.
  return (SCM_BOOL_F);
}

size_t
free_speller (SCM x)
{
  AspellSpeller *spl;

  assert (SCM_SMOB_PREDICATE (speller_tag, x));

  spl = (AspellSpeller *) SCM_SMOB_DATA (x);
  /* Spellers should already be null if delete_aspell_speller has been
     called on them */
  if (spl != NULL)
    {
      delete_aspell_speller (spl);
      SCM_SET_SMOB_DATA (x, 0);
    }

  return 0;
}

int
print_speller (SCM x, SCM port, scm_print_state * pstate)
{
  AspellSpeller *spl = (AspellSpeller *) SCM_SMOB_DATA (x);
  char *str;

  assert (SCM_SMOB_PREDICATE (speller_tag, x));

  scm_puts ("#<speller ", port);

  if (spl == 0)
    scm_puts ("(freed)", port);
  else
    {
      if (asprintf (&str, "%p", (void *) spl) < 0)
	scm_puts ("???", port);
      else
	scm_puts (str, port);
    }
  scm_puts (">", port);

  // non-zero means success
  return 1;
}

SCM
gu_is_speller_p (SCM x)
{
  return scm_from_bool (_scm_is_speller (x));
}

void
gu_aspell_cleanup ()
{
  delete_aspell_config (spell_config);
}

SCM
gu_aspell_set_lang (SCM lang)
{
  char *c_orig_lang;
  char *c_lang;
  int ret;

  SCM_ASSERT (scm_is_string (lang), lang, SCM_ARG1, "aspell-set-lang");

  c_orig_lang = strdup (aspell_config_retrieve (spell_config, "lang"));

  c_lang = scm_to_locale_string (lang);
  if (STREQ (c_orig_lang, c_lang))
    {
      free (c_orig_lang);
      free (c_lang);
      return SCM_BOOL_T;
    }

  ret = aspell_config_replace (spell_config, "lang", c_lang);
  /* aspell keeps c_lang.  We don't free it.  */

  if (!ret)
    {
      scm_misc_error ("aspell-set-lang",
		      aspell_config_error_message (spell_config), SCM_BOOL_F);
    }

  /* Reboot the default speller */
  {
    AspellCanHaveError *possible_err = new_aspell_speller (spell_config);
    if (aspell_error_number (possible_err) != 0)
      {
	const char *msg = aspell_error_message (possible_err);
	scm_misc_error ("aspell-set-lang", msg, SCM_BOOL_F);
      }
    else
      {
	delete_aspell_speller (default_speller);
	default_speller = to_aspell_speller (possible_err);
      }
  }
  return SCM_BOOL_T;
}

SCM
gu_aspell_correct_p (SCM word, SCM speller)
{
  AspellSpeller *c_speller;
  char *c_word;
  int correct;

  SCM_ASSERT (scm_is_string (word), word, SCM_ARG1, "aspell-correct?");

  if (!SCM_UNBNDP (speller) && !_scm_is_speller (speller))
    scm_wrong_type_arg ("aspell-correct?", SCM_ARG2, speller);

  if (SCM_UNBNDP (speller))
    c_speller = default_speller;
  else
    c_speller = _scm_to_speller (speller);

  c_word = scm_to_locale_string (word);

  correct = aspell_speller_check (c_speller, c_word, strlen (c_word));
  free (c_word);
  if (!correct)
    return SCM_BOOL_F;

  return SCM_BOOL_T;
}

SCM
gu_aspell_word (SCM word, SCM speller)
{
  AspellSpeller *c_speller;
  const AspellWordList *c_suggestions;
  AspellStringEnumeration *c_elements;
  char *c_word;
  const char *c_word2;
  SCM element, list;

  SCM_ASSERT (scm_is_string (word), word, SCM_ARG1, "aspell-word");

  if (!SCM_UNBNDP (speller) && !_scm_is_speller (speller))
    scm_wrong_type_arg ("aspell-word", SCM_ARG2, speller);

  if (SCM_UNBNDP (speller))
    c_speller = default_speller;
  else
    c_speller = _scm_to_speller (speller);

  c_word = scm_to_locale_string (word);

  c_suggestions
    = aspell_speller_suggest (c_speller, c_word,
			      strlen ((const char *) c_word));
  free (c_word);
  c_elements = aspell_word_list_elements (c_suggestions);
  list = SCM_EOL;
  while ((c_word2 = aspell_string_enumeration_next (c_elements)) != NULL)
    {
      element = scm_from_locale_string (c_word2);
      list = scm_append (scm_list_2 (list, scm_list_1 (element)));
    }
  delete_aspell_string_enumeration (c_elements);

  return list;
}

SCM
gu_aspell_add_word (SCM word, SCM speller)
{
  AspellSpeller *c_speller;
  char *c_word;
  int ret;

  SCM_ASSERT (scm_is_string (word), word, SCM_ARG1, "aspell-add-word");

  if (!SCM_UNBNDP (speller) && !_scm_is_speller (speller))
    scm_wrong_type_arg ("aspell-add-word", SCM_ARG2, speller);

  if (SCM_UNBNDP (speller))
    c_speller = default_speller;
  else
    c_speller = _scm_to_speller (speller);

  c_word = scm_to_locale_string (word);

  ret = aspell_speller_add_to_session (c_speller, c_word, strlen (c_word));

  free (c_word);
  if (!ret)
    {
      scm_misc_error ("aspell-add-word",
		      aspell_speller_error_message (c_speller), SCM_BOOL_F);
    }

  return SCM_BOOL_T;

}

SCM
gu_aspell_store_replacement (SCM misspelled, SCM correct, SCM speller)
{
  AspellSpeller *c_speller;
  char *c_misspelled, *c_correct;
  int ret;

  SCM_ASSERT (scm_is_string (misspelled), correct, SCM_ARG1,
	      "aspell-store-replacement");
  SCM_ASSERT (scm_is_string (correct), correct, SCM_ARG2,
	      "aspell-store-replacement");

  if (!SCM_UNBNDP (speller) && !_scm_is_speller (speller))
    scm_wrong_type_arg ("aspell-store-replacement", SCM_ARG3, speller);

  if (SCM_UNBNDP (speller))
    c_speller = default_speller;
  else
    c_speller = _scm_to_speller (speller);

  c_misspelled = scm_to_locale_string (misspelled);
  c_correct = scm_to_locale_string (correct);

  ret = aspell_speller_store_replacement (c_speller, c_misspelled,
					  strlen (c_misspelled),
					  c_correct, strlen (c_correct));
  free (c_misspelled);
  free (c_correct);

  if (!ret)
    {
      scm_misc_error ("aspell-store-replacement",
		      aspell_speller_error_message (c_speller), SCM_BOOL_F);
    }

  return SCM_BOOL_T;
}


void
gu_aspell_init ()
{
  static int first = 1;

  if (first)
    {
      spell_config = new_aspell_config ();
      atexit (gu_aspell_cleanup);

      speller_tag = scm_make_smob_type ("speller", sizeof (AspellSpeller *));
      // scm_set_smob_mark (speller_tag, mark_speller);
      scm_set_smob_free (speller_tag, free_speller);
      scm_set_smob_print (speller_tag, print_speller);
      scm_set_smob_equalp (speller_tag, equalp_speller);
      scm_c_define_gsubr ("%aspell-speller?", 1, 0, 0, gu_is_speller_p);

      scm_c_define_gsubr ("%aspell-new-speller", 0, 0, 0,
			  gu_aspell_new_speller);
      scm_c_define_gsubr ("%aspell-set-lang", 1, 0, 0, gu_aspell_set_lang);
      scm_c_define_gsubr ("%aspell-word", 1, 1, 0, gu_aspell_word);
      scm_c_define_gsubr ("%aspell-correct?", 1, 1, 0, gu_aspell_correct_p);
      scm_c_define_gsubr ("%aspell-add-word", 1, 1, 0, gu_aspell_add_word);
      scm_c_define_gsubr ("%aspell-store-replacement", 2, 1, 0,
			  gu_aspell_store_replacement);

      default_speller = _scm_to_speller (scm_permanent_object (gu_aspell_new_speller ()));
      first = 0;
    }
}
