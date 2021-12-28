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

    public int max_guesses { get; private set; default = 10; }
    public int code_length { get; private set; default = 4; }
    public int number_of_colors { get; private set; default = 6; }

    public int current_turn { get; set; default = 0; }

    public signal void game_over (bool victory, int[] code);

    private Gee.List<int> code;

    public Game () {
        code = generate_new_code ();
    }

    private Gee.List<int> generate_new_code () {
        var code = new Gee.ArrayList<int> ();
        for (int i = 0; i < code_length; i++) {
            code.add ((int) Random.int_range (0, number_of_colors));
        }

        return code;
    }

    public void reset () {
        current_turn = 0;
        code = generate_new_code ();
    }

    public Hint submit_a_guess (int[] guess) {
        var hint = check_a_guess (guess);

        if (hint.correct_positions_count == code_length) {
            game_over (true, code.to_array ());
            return hint;
        }

        if (current_turn == max_guesses - 1) {
            game_over (false, code.to_array ());
            return hint;
        }

        current_turn++;
        return hint;
    }

    private Hint check_a_guess (int[] guess) {
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

