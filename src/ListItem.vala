using Gtk;
using Gdk;

namespace Parole {

	[GtkTemplate (ui="/de/hannenz/parole/ui/list_item.ui")]
	public class ListItem : Gtk.Grid {

		[GtkChild]
		public Gtk.Image list_item_image;

		[GtkChild]
		public Gtk.Label list_item_label;

		public ListItem (Pixbuf? pixbuf, string label) {
			list_item_label.set_text (label);
			if (pixbuf != null) {
				list_item_image.set_from_pixbuf (pixbuf);
			}

			show_all ();
		}
	}
}
