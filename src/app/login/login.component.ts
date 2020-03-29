import { Component, OnInit } from '@angular/core';
import { ApiService } from '../api.service';
import { LoadingService } from '../loading.service';
import { Router } from '@angular/router';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {

  users = [];

  constructor(private ApiService: ApiService,
    private loadingService: LoadingService,
    public router: Router,
    public toastr: ToastrService) { }

  ngOnInit() {
    this.loadingService.loading.next(true);
    this.ApiService.getUsers().subscribe((users : any) => {
      this.users = users;
      console.log(this.users);
    });
    this.loadingService.loading.next(false);
  }

  login(inputuser, inputpassword) {
    let loggedin = false;
    this.loadingService.loading.next(true);
    for (let i = 0; i < this.users.length; i++) {
      if (this.users[i].username === inputuser) {
        if (this.users[i].password === inputpassword) {
          loggedin = true;
          if (this.users[i].user_role === 'rider') {
            this.router.navigate([`/rider/${this.users[i].username}`]);
          } else if (this.users[i].user_role === 'staff') {
            this.router.navigate([`/staff/${this.users[i].username}`]);
          } else if (this.users[i].user_role === 'customer') {
            this.router.navigate([`/customer/${this.users[i].username}`]);
          } else {
            this.router.navigate([`/manager/${this.users[i].username}`]);
          }
        } else {
          this.toastr.show("Wrong password!");
          this.loadingService.loading.next(false);
          return;
        }
      } else {
        continue;
      }
    }
    if (loggedin) {
      this.toastr.show("Success!");
    } else {
      this.toastr.show("No such user");
    }
    this.loadingService.loading.next(false);
  }

  register() {
    this.router.navigate(['/register']);
  }

}
