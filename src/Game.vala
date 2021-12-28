/*
* Copyright 2021 Josip Antoliš. (https://josipantolis.from.hr)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/

public class Sage.Game : Object {

    public const int EMPTY_GUESS = -1;

    public int max_guesses { get; private set; default = 10; }
    public int code_length { get; private set; default = 4; }
    public int number_of_colors { get; private set; default = 6; }

    public int current_turn { get; set; default = 0; }
    public Gee.List<Hint> hints { get; set; }
    public Gee.List<Gee.List<int>> guesses { get; set; }
    public bool can_validate { get; set; }

    public signal void game_over (bool victory, int[] code);

    private Gee.List<int> code;

    public Game () {
        reset ();
    }

    public void reset () {
        current_turn = 0;
        code = generate_new_code ();
        hints = generate_empty_hints ();
        guesses = generate_empty_guesses ();
        can_validate = current_turn_guesses_are_full();
    }

    private Gee.List<int> generate_new_code () {
        var code = new Gee.ArrayList<int> ();
        for (int i = 0; i < code_length; i++) {
            code.add ((int) Random.int_range (0, number_of_colors));
        }

        return code;
    }

    private Gee.List<Hint> generate_empty_hints () {
        var hints = new Gee.ArrayList<Hint> ();
        for (int i = 0; i < max_guesses; i ++) {
            hints.add (new Hint ());
        }

        return hints;
    }

    private Gee.List<Gee.List<int>> generate_empty_guesses () {
        var all_guesses = new Gee.ArrayList<Gee.ArrayList<int>> ();
        for (int i = 0; i < max_guesses; i++) {
            var row = new Gee.ArrayList<int> ();
            for (int j = 0; j < code_length; j++) {
                row.add (EMPTY_GUESS);
            }

            all_guesses.add (row);
        }

        return all_guesses;
    }

    private bool current_turn_guesses_are_full () {
        var ok = true;
        foreach (var guess in guesses[current_turn]) {
            ok = ok && guess != EMPTY_GUESS;
        }

        return ok;
    }

    public void submit_a_guess (int i, int guess) {
        Gee.List<int>[] guesses_a = guesses.to_array ();
        int[] row_a = guesses_a[current_turn].to_array ();
        row_a[i] = guess;
        guesses_a[current_turn] = new Gee.ArrayList<int>.wrap (row_a);
        guesses = new Gee.ArrayList<Gee.List<int>>.wrap (guesses_a);
        can_validate = current_turn_guesses_are_full();
    }

    public void validate_current_row () {
        var guess = guesses[current_turn].to_array ();
        var hint = validate_a_guess (guess);
        Hint[] hints_a = hints.to_array ();
        hints_a[current_turn] = hint;
        hints = new Gee.ArrayList<Hint>.wrap (hints_a);

        if (hint.correct_positions_count == code_length) {
            game_over (true, code.to_array ());
            return;
        }

        if (current_turn == max_guesses - 1) {
            game_over (false, code.to_array ());
            return;
        }

        current_turn++;
        can_validate = false;
    }

    private Hint validate_a_guess (int[] guess) {
        int correct_colors = 0;
        int correct_positions = 0;
        var helper = new Gee.ArrayList<int>.wrap (code.to_array ());
        for (int i = 0; i < code_length; i++) {
            if (guess[i] == code[i]) {
                correct_positions++;
            }

            if (helper.contains(guess[i])) {
                correct_colors++;
                helper.remove (guess[i]);
            }
        }

        return new Hint (correct_colors, correct_positions);
    }
}

