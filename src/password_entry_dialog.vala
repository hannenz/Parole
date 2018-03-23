using Gtk;

namespace Parole {
	
	[GtkTemplate (ui="/de/hannenz/parole/entry_dialog.ui")]
	public class PasswordEntryDialog : Gtk.Dialog {

		[GtkChild]
		private Gtk.Entry titleEntry;

		[GtkChild]
		private Gtk.Entry urlEntry;

		[GtkChild]
		private Gtk.Entry usernameEntry;

		[GtkChild]
		private Gtk.Entry secretEntry;

		[GtkChild]
		private Gtk.TextView remarkEntry;

		[GtkChild]
		private Gtk.Spinner pwned_spinner;

		[GtkChild]
		private Gtk.Label pwned_label;

		private PasswordGenerator generator;

		private string category;

		public PasswordEntry pwEntry;

		[GtkCallback]
		private void on_generate_password_button_clicked () {
			debug ("Button has been clicked");
			generator.regenerate_password ();
			generator.show_all ();
		}

		private void check_if_pawned () {

			var password = secretEntry.get_text ();
			if (password.length == 0) {
				return;
			}
			debug ("Checking password:  %s\n".printf (password));

			// Get SHA1 hash of password
			var hash = GLib.Checksum.compute_for_string (ChecksumType.SHA1, password);

			string url = "https://api.pwnedpasswords.com/pwnedpassword/%s".printf (hash);
			var session = new Soup.Session ();
			var message = new Soup.Message ("GET", url);

			pwned_spinner.start ();
			session.queue_message (message, (session, message) => {
				pwned_spinner.stop ();
				pwned_spinner.hide ();
				pwned_label.set_label (message.status_code == 404 ? "ok" : "pwned");
				pwned_label.show ();
			});
		}


		public PasswordEntryDialog (PasswordEntry? pwEntry, string category) {

			this.pwEntry = pwEntry;
			this.category = category;
			
			this.title = pwEntry.title + " in " + category;
			this.set_default_size(500, 300);

			if (pwEntry != null) {
				titleEntry.set_text (pwEntry.title);
				urlEntry.set_text (pwEntry.url);
				usernameEntry.set_text (pwEntry.username);
				secretEntry.set_text (pwEntry.secret);
				remarkEntry.buffer.text = pwEntry.remark;
			}
			this.response.connect(on_response);

			generator = new PasswordGenerator ();
			generator.set_relative_to (secretEntry);
			check_if_pawned ();

			secretEntry.focus_in_event.connect ( () => {
				secretEntry.set_visibility (true);
				return false;
			});
			secretEntry.focus_out_event.connect ( () => {
				secretEntry.set_visibility (false);
				return false;
			});

		}

		private void create_widgets () {

			var grid = new Gtk.Grid();
			grid.set_column_spacing(10);
			grid.set_row_spacing(10);
			grid.set_column_homogeneous(true);
			grid.set_row_homogeneous(false);

			grid.attach(new Gtk.Label("Title"), 0, 0, 1, 1);

			titleEntry = new Gtk.Entry();
			grid.attach(titleEntry, 1, 0, 1, 1);
			if (pwEntry != null) {
				titleEntry.set_text(pwEntry.title);
			}

			grid.attach(new Gtk.Label("URL"), 0, 1, 1, 1);
			urlEntry = new Gtk.Entry();
			grid.attach(urlEntry, 1, 1, 1, 1);
			if (pwEntry != null) {
				urlEntry.set_text(pwEntry.url);
			}

			grid.attach(new Gtk.Label("Username"), 0, 2, 1, 1);
			usernameEntry = new Gtk.Entry();
			grid.attach(usernameEntry, 1, 2, 1, 1);
			if (pwEntry != null) {
				usernameEntry.set_text(pwEntry.username);
			}

			grid.attach(new Gtk.Label("Secret"), 0, 3, 1, 1);
			secretEntry = new Gtk.Entry();
			grid.attach(secretEntry, 1, 3, 1, 1);
			if (pwEntry != null) {
				secretEntry.set_text(pwEntry.secret);
			}

			grid.attach(new Gtk.Label("Remark"), 0, 4, 1, 1);
			remarkEntry = new Gtk.TextView();
			remarkEntry.set_wrap_mode(WrapMode.WORD);

			var swin = new Gtk.ScrolledWindow(null, null);
			swin.add(remarkEntry);
			grid.attach(swin, 1, 4, 1, 1);
			if (pwEntry != null) {
				remarkEntry.buffer.text = pwEntry.remark;
			}

			Gtk.Box contentArea = get_content_area() as Gtk.Box;
			contentArea.pack_start(grid);

			add_button("_Save", Gtk.ResponseType.APPLY);
			add_button("_Cancel", Gtk.ResponseType.CANCEL);

		}

		private void connect_signals() {

			this.response.connect(on_response);

		}

		private void on_response(Gtk.Dialog source, int response_id) {
			switch (response_id) {
				case Gtk.ResponseType.CANCEL:
					this.destroy();
					break;
				case Gtk.ResponseType.APPLY:
					debug ("Updating passwordEntry object!");
					this.pwEntry.title = titleEntry.get_text();
					this.pwEntry.url = urlEntry.get_text();
					this.pwEntry.username = usernameEntry.get_text();
					this.pwEntry.secret = secretEntry.get_text();
					this.pwEntry.remark = remarkEntry.buffer.text;
					break;
			}
		}
	}
}
