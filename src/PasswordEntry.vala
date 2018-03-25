namespace Parole {

	public class PasswordEntry {

		public string title;

		public string url;

		public string username;

		public string secret;

		public string remark;

		public Gdk.Pixbuf pixbuf;

		public Xml.Node xml_node;

		public void dump () {
			debug ("title:     %s\n".printf (title));
			debug ("url:       %s\n".printf (url));
			debug ("username:  %s\n".printf (username));
			debug ("secret:    %s\n".printf (secret));
			debug ("remark:    %s\n".printf (remark));
		}

		/* public bool account_is_pawned; */
        /*  */
		/* public bool secret_is_pawned; */
        /*  */
        /*  */
        /*  */
		/* private bool check_if_secret_is_pawned () { */
        /*  */
		/* 	var password = secretEntry.get_text (); */
		/* 	if (password.length == 0) { */
		/* 		return; */
		/* 	} */
		/* 	debug ("Checking password:  %s\n".printf (password)); */
        /*  */
		/* 	// Get SHA1 hash of password */
		/* 	var hash = GLib.Checksum.compute_for_string (ChecksumType.SHA1, password); */
        /*  */
		/* 	string url = "https://api.pwnedpasswords.com/pwnedpassword/%s".printf (hash); */
		/* 	var session = new Soup.Session (); */
		/* 	var message = new Soup.Message ("GET", url); */
        /*  */
			/* pwned_spinner.start (); */
		/* 	session.queue_message (message, (session, message) => { */
		/* 		pwned_spinner.stop (); */
		/* 		pwned_spinner.hide (); */
		/* 		pwned_label.set_label (message.status_code == 404 ? "ok" : "pwned"); */
		/* 		pwned_label.show (); */
		/* 	}); */
		/* } */
        /*  */
		/* private bool check_if_username_has_been_pawned () { */
        /*  */
		/* 	string url = "https://haveibeenpawned.com/api/v2/breachedaccount/%s".printf (Soup.URL.encode (username)); */
		/* 	var session = new Soup.Session (); */
		/* 	var message = new Soup.Message ("GET", url); */
        /*  */
		/* 	session.queue_message (message, (session, message) => { */
		/* 		if () { */
		/* 			account_is_pawned = true; */
		/* 		} */
		/* 		else { */
		/* 			account_is_pawned = false; */
		/* 		} */
		/* 	} */
		/* } */
        /*  */

	}
}
