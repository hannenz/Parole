namespace Parole {
	
	public class Parole : Gtk.Application {

		private ApplicationWindow window;

		private string _master_password;
		public string master_password {
			get { return _master_password; }
			set { _master_password = value; }
		}

		public Parole () {
			application_id = "de.hannenz.parole";
			flags |= GLib.ApplicationFlags.HANDLES_OPEN;

			this.master_password = "";
		}

		public override void activate () {

			// Load Stylel Sheet (Custom CSS)
			var screen = Gdk.Display.get_default ().get_default_screen ();
			var provider = new Gtk.CssProvider ();
			provider.load_from_resource ("de/hannenz/parole/parole.css");
			Gtk.StyleContext.add_provider_for_screen (screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

			window = new ApplicationWindow (this);
			window.present();

			var entry = Unity.LauncherEntry.get_for_desktop_id ("de.hannenz.parole.desktop");
			entry.count_visible = true;
			entry.count = 12;

			// Create a root quicklist
			var quicklist = new Dbusmenu.Menuitem ();

			// Create root's children
			var item1 = new Dbusmenu.Menuitem ();
			item1.property_set (Dbusmenu.MENUITEM_PROP_LABEL, "Item 1");
			item1.item_activated.connect (() => {
				message ("Item 1 activated");
			});

			var item2 = new Dbusmenu.Menuitem ();
			item2.property_set (Dbusmenu.MENUITEM_PROP_LABEL, "Item 2");
			item2.item_activated.connect (() => {
				message ("Item 2 activated");
			});

			// Add children to the quicklist
			quicklist.child_append (item1);
			quicklist.child_append (item2);

			// Finally, tell libunity to show the desired quicklist
			entry.quicklist = quicklist;
		}

		public override void open (GLib.File[] files, string hint){
			if (window == null){
				window = new ApplicationWindow	 (this);
			}
			foreach (var file in files) {
				window.open (file);
			}
			window.present();
		}
	}
}
