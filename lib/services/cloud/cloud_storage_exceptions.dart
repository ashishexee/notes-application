// @immutable // immutable means all the instance field inside this class shall be final (we are not using immutable here)
// for example
// you cant say that int ashish; ,,,, you have to say final int ashish;

class CloudStorageExceptions implements Exception {
  const CloudStorageExceptions();
}

class CouldNotCreateNoteException implements Exception {} // C of crud => create

class CouldNotgetallnotesexception implements Exception {} // R of crud => read

class Couldnotupdatenoteexception implements Exception {} // U of crud => update

class Couldnotdeletenoteexception implements Exception{} // D of crud => delete