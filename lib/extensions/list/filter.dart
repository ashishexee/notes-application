// extension is basically the feature that allows you to add more functionality to a class without modifying the existing class

extension Filter<T> on Stream<List<T>> {
  // this line tells us that we need to put the filter onto the stream of list of T
  Stream<List<T>> filter(bool Function(T) where) {
    // if true the item is kept and if false the item is discarded
    // this function put the T under a function and check if it passes for not
    return map((items) => items
        .where(where)
        .toList()); // if the function passes then we will map those items to the correct items and return them
  }
}

// for example
// Stream<List<String>> names = Stream.value([
//   'ashish',
//   'ayush',
//   'khushal',
//   'lakshya bhatt',
//   'ankit',
//   'himanshu',
//   'divyanshu'
// ]);
// Stream<List<String>> final_names = names.filter((name) {
//   return name.startsWith("a");
// });
// or
// Stream<List<String>> final_name_1 = names.filter((name) => name.startsWith('a'));
