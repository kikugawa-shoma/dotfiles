package main

import (
	"errors"
	"fmt"
	"strings"
)

// User はLSPのホバー表示やドキュメント補完の確認用の構造体。
type User struct {
	Name string
	Age  int
}

// Greet は挨拶文を返す。メソッド補完・シグネチャヘルプの確認に使う。
func (u User) Greet() string {
	return fmt.Sprintf("Hello, %s! You are %d years old.", u.Name, u.Age)
}

// FindUser は名前からユーザーを探す。エラーハンドリング系の診断確認用。
func FindUser(users []User, name string) (User, error) {
	for _, u := range users {
		if strings.EqualFold(u.Name, name) {
			return u, nil
		}
	}
	return User{}, errors.New("user not found: " + name)
}

func main() {
	users := []User{
		{
			Name: "Alice",
			Age:  30},
		{Name: "Bob", Age: 25},
	}

	for _, u := range users {
		fmt.Println(u.Greet())
	}

	if u, err := FindUser(users, "alice"); err == nil {
		fmt.Println("found:", u.Name)
	}
}
