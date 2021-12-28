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

public class Sage.MainWindow : Hdy.ApplicationWindow {

    public Application app { get; construct; }
    public Game game { get; construct; }

    private Gtk.Grid grid;
    private Widgets.BoardGrid board;

    public MainWindow (Application application) {
        Object (
            app: application,
            game: new Game (),
            application: application,
            height_request: 640,
            width_request: 420,
            resizable: false,
            title: _("Sage")
        );
    }

    static construct {
        load_style ();
    }


    private static void load_style () {
        var provider = new Gtk.CssProvider();
        provider.load_from_resource ("hr/from/josipantolis/sage/style.css");
        var screen = Gdk.Screen.get_default ();
        Gtk.StyleContext.add_provider_for_screen (
            screen,
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
    }

    construct {
        create_layout ();
        listen_to_game_over ();
        show_all ();
    }

    private void create_layout () {
        var header_bar = new Hdy.HeaderBar () {
            title = _("Sage"),
            has_subtitle = false,
            show_close_button = true,
            decoration_layout = "close",
            hexpand = true,
        };

        grid = new Gtk.Grid ();
        grid.attach (header_bar, 0, 0);
        board = new Widgets.BoardGrid (game);
        grid.attach (board, 0, 1);
        add (grid);
    }

    private void listen_to_game_over () {
        game.game_over.connect ((victory, code) => {
            Widgets.EndGameDialog dialog;
            if (victory) {
                dialog = new Widgets.EndGameDialog ();
            } else {
                dialog = new Widgets.EndGameDialog.defeat ();
            }

            dialog.transient_for = this;
            dialog.display_code (code);

            var response_id = dialog.run ();
            if (response_id == Gtk.ResponseType.ACCEPT) {
                reset_game ();
            } else {
                application.quit ();
            }

            dialog.destroy ();
        });
    }

    private void reset_game () {
        grid.remove_row (1);
        board.destroy ();
        game.reset ();
        board = new Widgets.BoardGrid (game);
        grid.attach (board, 0, 1);
        grid.show_all ();
    }
}

