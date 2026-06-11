#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

// LSP（clangd）のホバー表示や補完の確認用クラス。
class User {
public:
  User(std::string name, int age) : name_(std::move(name)), age_(age) {}

  // メソッド補完・シグネチャヘルプの確認に使う。
  std::string greet() const {
    return "Hello, " + name_ + "! You are " + std::to_string(age_) +
           " years old.";
  }

  const std::string &name() const { return name_; }
  int age() const { return age_; }

private:
  std::string name_;
  int age_;
};

int main() {
  std::vector<User> users{
      {"Alice", 30},
      {"Bob", 25},
  };

  for (const auto &user : users) {
    std::cout << user.greet() << '\n';
  }

  auto it = std::find_if(users.begin(), users.end(),
                         [](const User &u) { return u.name() == "Alice"; });
  if (it != users.end()) {
    std::cout << "found: " << it->name() << '\n';
  }

  return 0;
}
