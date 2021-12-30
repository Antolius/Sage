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

public class Sage.Widgets.ValidateRowButton : Gtk.Button {

    public Game game { get; construct; }
    public int row { get; construct; }

    private Gtk.Popover? help_popover;

    public ValidateRowButton (Game game, int row) {
        Object (
            game: game,
            row: row,
            image: new Gtk.Image () {
                gicon = new ThemedIcon ("insert-object-symbolic"),
                pixel_size = 24
            }
        );
    }

    construct {
        margin_end = 8;
        margin_top = 8;
        margin_bottom = 8;
        sensitive = false;
        always_show_image = true;
        visible = false;
        tooltip_text = _("Compare with code");
        get_style_context ().add_class ("circular");

        clicked.connect (() => game.validate_current_row ());
        update_validate_button ();
        game.notify["can-validate"].connect (update_validate_button);
        game.notify["help-tour-step"].connect (update_help_popover);
    }

    public override void show_all () {
        var is_on_turn = row == game.current_turn;
        if (is_on_turn) {
            base.show_all ();
        }
    }

    private void update_validate_button () {
        var is_on_turn = row == game.current_turn;
        sensitive = is_on_turn && game.can_validate;
        visible = is_on_turn;
    }

    private void update_help_popover () {
        var on_turn = game.current_turn == row;
        var validate_help = game.help_tour_step == Game.VALIDATE_HELP;
        if (on_turn && validate_help) {
            if (help_popover == null) {
                help_popover = new HelpPopover (this, Game.VALIDATE_HELP);
                help_popover.show_all ();
            }

            help_popover.popup ();
        } else if (help_popover != null) {
            help_popover.popdown ();
            help_popover.destroy ();
            help_popover = null;
        }
    }
}
