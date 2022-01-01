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
    public const int NO_HELP = 0;
    public const int GUESS_HELP = 1;
    public const int VALIDATE_HELP = 2;
    public const int HINT_HELP = 3;

    public int max_guesses { get; set; }
    public int code_length { get; set; }
    public int number_of_colors { get; set; }

    public int current_turn { get; set; }
    public Gee.List<Hint> hints { get; set; }
    public Gee.List<Gee.List<int>> guesses { get; set; }
    public bool can_validate { get; set; }
    public int help_tour_step { get; set; default = 0; }

    public signal void game_over (bool victory, int[] code);
    public signal void game_reset_started ();
    public signal void game_reset_finished ();

    private Settings state;
    private Gee.List<int> code;

    public Game (Settings state) {
        this.state = state;
        link_to_state ();
    }

    private void link_to_state () {
        var flags = GLib.SettingsBindFlags.DEFAULT;
        state.bind ("max-guesses", this, "max-guesses", flags);
        state.bind ("code-length", this, "code-length", flags);
        state.bind ("number-of-colors", this, "number-of-colors", flags);
        state.bind ("current-turn", this, "current-turn", flags);
        state.bind ("can-validate", this, "can-validate", flags);

        read_code_from (state.get_value ("code"));
        read_hints_from (state.get_value ("hints"));
        read_guesses_from (state.get_value ("guesses"));
    }

    private void read_code_from (Variant variant) {
        var iter = variant.iterator ();
        if (iter.n_children () == 0) {
            code = generate_new_code ();
            store_code.begin ();
            return;
        }

        code = new Gee.ArrayList<int> ();
        int el;
        while (iter.next ("i", out el)) {
            code.add (el);
        }
    }

    private void read_hints_from (Variant variant) {
        var iter = variant.iterator ();
        if (iter.n_children () == 0) {
            hints = generate_empty_hints ();
            store_hints.begin ();
            return;
        }

        hints = new Gee.ArrayList<Hint> ();
        int correct_colors;
        int correct_positions;
        while (iter.next ("(ii)", out correct_colors, out correct_positions)) {
            hints.add (new Hint (correct_colors, correct_positions));
        }
    }

    private void read_guesses_from (Variant variant) {
        var outer_iter = variant.iterator ();
        if (outer_iter.n_children () == 0) {
            guesses = generate_empty_guesses ();
            store_guesses.begin ();
            return;
        }

        guesses = new Gee.ArrayList<Gee.ArrayList<int>> ();
        Variant inner_var = outer_iter.next_value ();
        while (inner_var != null) {
            var inner_iter = inner_var.iterator ();
            var row = new Gee.ArrayList<int> ();
            int guess;
            while (inner_iter.next ("i", out guess)) {
                row.add (guess);
            }

            guesses.add (row);
            inner_var = outer_iter.next_value ();
        }
    }

    public void reset () {
        game_reset_started ();
        reset_game_state ();
        game_reset_finished ();
    }

    public void quit () {
        current_turn = 0;
        help_tour_step = 0;
        can_validate = false;
        var code_v = new Variant.array (new VariantType ("i"), {});
        state.set_value ("code", code_v);
        var hints_v = new Variant.array (new VariantType ("(ii)"), {});
        state.set_value ("hints", hints_v);
        var guesses_v = new Variant.array (new VariantType ("ai"), {});
        state.set_value ("guesses", guesses_v);
    }

    public void reconfigure (int code_length, int number_of_colors) {
        game_reset_started ();
        this.code_length = code_length;
        this.number_of_colors = number_of_colors;
        reset_game_state ();
        game_reset_finished ();
    }

    private void reset_game_state () {
        current_turn = 0;
        help_tour_step = 0;
        code = generate_new_code ();
        store_code.begin ();
        hints = generate_empty_hints ();
        store_hints.begin ();
        guesses = generate_empty_guesses ();
        store_guesses.begin ();
        can_validate = false;
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
        var guesses = new Gee.ArrayList<Gee.ArrayList<int>> ();
        for (int i = 0; i < max_guesses; i++) {
            var row = new Gee.ArrayList<int> ();
            for (int j = 0; j < code_length; j++) {
                row.add (EMPTY_GUESS);
            }

            guesses.add (row);
        }

        return guesses;
    }

    public void submit_a_guess (int i, int guess) {
        Gee.List<int>[] guesses_a = guesses.to_array ();
        int[] row_a = guesses_a[current_turn].to_array ();
        row_a[i] = guess;
        guesses_a[current_turn] = new Gee.ArrayList<int>.wrap (row_a);
        guesses = new Gee.ArrayList<Gee.List<int>>.wrap (guesses_a);
        can_validate = current_turn_guesses_are_full ();
        update_help_tour_after_guess_submission ();
        store_guesses.begin ();
    }

    private bool current_turn_guesses_are_full () {
        var ok = true;
        foreach (var guess in guesses[current_turn]) {
            ok = ok && guess != EMPTY_GUESS;
        }

        return ok;
    }

    public void validate_current_row () {
        var guess = guesses[current_turn].to_array ();
        var hint = validate_a_guess (guess);
        Hint[] hints_a = hints.to_array ();
        hints_a[current_turn] = hint;
        hints = new Gee.ArrayList<Hint>.wrap (hints_a);
        store_hints.begin ();

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
        update_help_tour_after_validation ();
    }

    private Hint validate_a_guess (int[] guess) {
        int correct_colors = 0;
        int correct_positions = 0;
        var helper = new Gee.ArrayList<int>.wrap (code.to_array ());
        for (int i = 0; i < code_length; i++) {
            if (guess[i] == code[i]) {
                correct_positions++;
            }

            if (helper.contains (guess[i])) {
                correct_colors++;
                helper.remove (guess[i]);
            }
        }

        return new Hint (correct_colors, correct_positions);
    }

    private async void store_code () {
        Idle.add (store_code.callback);
        yield;
        var elements = new Variant[code_length];
        for (int i = 0; i < code_length; i++) {
            elements[i] = new Variant.int32 ((int32) code[i]);
        }

        var code_v = new Variant.array (new VariantType ("i"), elements);
        state.set_value ("code", code_v);
    }

    private async void store_hints () {
        Idle.add (store_hints.callback);
        yield;
        var elements = new Variant[max_guesses];
        for (int i = 0; i < max_guesses; i++) {
            var hint = hints[i];
            elements[i] = new Variant.tuple ({
                new Variant.int32 ((int32) hint.correct_colors_count),
                new Variant.int32 ((int32) hint.correct_positions_count)
            });
        }

        var hints_v = new Variant.array (new VariantType ("(ii)"), elements);
        state.set_value ("hints", hints_v);
    }

    private async void store_guesses () {
        Idle.add (store_guesses.callback);
        yield;
        var outer_els = new Variant[max_guesses];
        for (int i = 0; i < max_guesses; i++) {
            var inner_els = new Variant[code_length];
            for (int j = 0; j < code_length; j++) {
                var guess = guesses[i][j];
                inner_els[j] = new Variant.int32 ((int32) guess);
            }

            outer_els[i] = new Variant.array (new VariantType ("i"), inner_els);
        }

        var guesses_v = new Variant.array (new VariantType ("ai"), outer_els);
        state.set_value ("guesses", guesses_v);
    }

    public void toggle_help_tour () {
        if (help_tour_step > NO_HELP) {
            help_tour_step = NO_HELP;
        } else if (can_validate) {
            help_tour_step = VALIDATE_HELP;
        } else {
            help_tour_step = GUESS_HELP;
        }
    }

    private void update_help_tour_after_guess_submission () {
        if (help_tour_step == GUESS_HELP && can_validate) {
            // player toggled all the pins while help on guessing is shown
            help_tour_step = VALIDATE_HELP;
        } else if (help_tour_step == VALIDATE_HELP && !can_validate) {
            // player untoggled a pin while help on validate button is shown
            help_tour_step = GUESS_HELP;
        } else if (help_tour_step == HINT_HELP) {
            // player toggled a pin while help on hits is shown
            help_tour_step = NO_HELP;
        }
    }

    private void update_help_tour_after_validation () {
        if (help_tour_step == VALIDATE_HELP) {
            help_tour_step = HINT_HELP;
        }
    }
}
