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
