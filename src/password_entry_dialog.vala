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

		private string category;

		public PasswordEntry pwEntry;

		[GtkChild]
		private Gtk.Popover generator;

		[GtkChild]
		private Gtk.Entry generated_password_entry;

		[GtkChild]
		private Gtk.SpinButton generator_spin_button;

		/* [GtkCallback] */
		/* private void on_pwned_button_clicked () { */
		/* } */

		[GtkCallback]
		private void on_generate_password_button_clicked () {
			/* var popover = new Popover (secretEntry); */
			var label = new Gtk.Label ("Generate a password");
			/* popover.set_border (10); */
			generator.show_all ();
			regenerate_password ();
		}

		[GtkCallback]
		private void on_generator_spin_button_value_changed () {
			regenerate_password ();

		}

		private void regenerate_password () {
			int exit_status;
			string standard_output, standard_error;
			Process.spawn_command_line_sync ("pwgen %u 1".printf (generator_spin_button.get_value_as_int ()), out standard_output,
                                               out standard_error,
                                               out exit_status);

			generated_password_entry.set_text (standard_output.chomp ());
		}

		private void check_if_pawned () {

			var password = secretEntry.get_text ();
			if (password.length == 0) {
				return;
			}
			message ("Checking password:  %s\n".printf (password));

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

			check_if_pawned ();
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
