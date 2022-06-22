# Vietnamese spelling and pronunciation variant generator

This is a component of a dictionary application I wrote, which has a feature where people can lookup words based on how they heard them and it'll search the dictionary for perhaps how the word is actually spelt. For an english example, imagine a learner hearing the word "knight" but as "night" so they can search for "night" and actually find the result for "knight".

In this case it's more for like, okay, you heard a northern say tình but northerners pronounce -inh as -ing so it'll show results for tình when you write tìng (the search accepts phonemes...? that aren't part of Vietnamese). Or if you hear a southerner saying lằn or từng but the word you want is actually lần or tuần. No longer do you have to search the dictionary for each possible variant of what you heard!!!

Now, there are actually still a lot of variants missing from this, and HEAPS of bugs and maybe I'll get to them one day, but here's how it exists now in its actual form. Actually as I wrote this, I realised a bug is I only implemented the tuần/từng pronunciation variant ONE WAY. Whoops.

Edit: Why didn't I make it work by being able to write... specifications... without... code. Hah!
