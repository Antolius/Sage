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

public class Sage.Widgets.ColorPickerButton : Granite.Widgets.ModeButton {

    public Game game { get; construct; }

    public ColorPickerButton (Game game) {
        Object (game: game);
    }

    construct {
        for (int i = 0; i < game.number_of_colors; i++) {
            var color = new Gdk.Pixbuf (Gdk.Colorspace.RGB, true, 8, 32, 32);
            color.fill (Colors.CODE[i]);
            append_pixbuf (color);
        }
    }
}

