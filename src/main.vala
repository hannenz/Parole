
namespace Parole {

    public static int main (string[] args) {


		// Test API
		/* string password = args[1]; */

        var application = new Parole ();
        return application.run (args);
    }
}
