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
    private uint configure_id;

    public MainWindow (Application application) {
        Object (
            app: application,
            game: new Game (application.state),
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
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("hr/from/josipantolis/sage/style.css");
        var screen = Gdk.Screen.get_default ();
        Gtk.StyleContext.add_provider_for_screen (
            screen,
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
    }

    construct {
        link_position_to_state ();
        create_layout ();
        listen_to_game_over ();
        show_all ();
    }

    private void link_position_to_state () {
        int window_x, window_y;
        app.state.get ("window-position", "(ii)", out window_x, out window_y);
        if (window_x != -1 || window_y != -1) {
            move (window_x, window_y);
        }
    }

    public override bool configure_event (Gdk.EventConfigure event) {
        if (configure_id != 0) {
            GLib.Source.remove (configure_id);
        }

        configure_id = Timeout.add (100, () => {
            configure_id = 0;
            int window_x, window_y;
            get_position (out window_x, out window_y);
            app.state.set ("window-position", "(ii)", window_x, window_y);

            return false;
        });

        return base.configure_event (event);
    }

    private void create_layout () {
        grid = new Gtk.Grid ();
        var header_bar = new Widgets.HeaderBar (game);
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
                game.reset ();
            } else {
                game.reset ();
                application.quit ();
            }

            dialog.destroy ();
        });
    }
}
