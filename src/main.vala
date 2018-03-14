
namespace Parole {

    public static int main (string[] args) {

		var ctx = new GPG.Context ();

        var application = new Parole ();
        return application.run (args);
    }
}
