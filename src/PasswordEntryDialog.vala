using Gtk;

namespace Parole {
	
	[GtkTemplate (ui="/de/hannenz/parole/ui/entry_dialog.ui")]
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

		[GtkChild]
		private Gtk.Image image;

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
				/* secretEntry.set_visibility (false); */
				return false;
			});

			/* if (this.pwEntry.pixbuf != null) { */
			/* 	image.set_from_pixbuf (this.pwEntry.pixbuf); */
			/* } */

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

		[GtkCallback]
		private void select_image_from_disk () {
			var  dlg = new Gtk.FileChooserDialog ("Select image", this, Gtk.FileChooserAction.OPEN, "_Cancel", Gtk.ResponseType.CANCEL, "_Open", Gtk.ResponseType.ACCEPT);

			var filter = new Gtk.FileFilter ();
			dlg.set_filter (filter);
			filter.add_mime_type ("image/jpeg");
			filter.add_mime_type ("image/png");

			if (dlg.run () == Gtk.ResponseType.ACCEPT) {

				var filename = dlg.get_filename ();

				debug (filename);

				pwEntry.pixbuf = new Gdk.Pixbuf.from_file_at_size (filename, -1, 120);
				image.set_from_pixbuf (pwEntry.pixbuf);
			}

			dlg.close ();
			dlg.destroy ();
		}
	}
}
