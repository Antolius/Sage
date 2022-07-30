/*
* Copyright 2022 Josip Antoliš. (https://josipantolis.from.hr)
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

public class Sage.MainWindow : Gtk.ApplicationWindow {

    public Game game { get; construct; }
    public Store store { get; construct; }

    public MainWindow (Application application, Store store, Game game) {
        Object (
            game: game,
            store: store,
            application: application,
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
        var display = Gdk.Display.get_default ();
        Gtk.StyleContext.add_provider_for_display (
            display,
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
    }

    construct {
        create_layout ();
        listen_to_game_over ();
    }

    private void create_layout () {
        set_titlebar (new Widgets.HeaderBar (game));
        child = new Widgets.BoardGrid (game);
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

            dialog.response.connect ((response_id) => {
                if (response_id == Gtk.ResponseType.ACCEPT) {
                    game.reset ();
                } else {
                    game.quit ();
                    application.quit ();
                }

                dialog.destroy ();
            });

            dialog.show ();
        });
    }
}
