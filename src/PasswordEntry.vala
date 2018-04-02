namespace Parole {

	public class PasswordEntry {

		public string title;

		public string url;

		public string username;

		public string secret;

		public string remark;

		public string image_data;

		public Gdk.Pixbuf pixbuf;

		public Xml.Node xml_node;

		public void dump () {
			debug ("title:     %s\n".printf (title));
			debug ("url:       %s\n".printf (url));
			debug ("username:  %s\n".printf (username));
			debug ("secret:    %s\n".printf (secret));
			debug ("remark:    %s\n".printf (remark));
		}
	}
}
