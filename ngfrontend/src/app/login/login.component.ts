import { Component, SimpleChanges, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { UserService } from './../services/user.service';

import { map } from 'rxjs/operators';

@Component({
  selector: 'login',
  styleUrls: ['login.component.scss'],
  templateUrl: 'login.component.html'
})
export class LoginComponent implements OnInit {
  message: string;
  disableForm: boolean = false;

  loginForm = this.fb.group({
    username: ['', Validators.required],
    password: ['', Validators.required]
  });

  constructor(
    private fb: FormBuilder,
    private userService: UserService,
    private router: Router
  ) {}

  ngOnInit() {
    this.loginForm.valueChanges
      .pipe(
        map(value => {
          value.username = value.username.trim();
          value.password = value.password.trim();
        })
      )
      .subscribe(val => {
        this.disableForm = false;
        this.message = '';
      });
  }

  onSubmit() {
    this.message = '';

    this.userService.login(this.loginForm.value).subscribe(response => {
      if (response.success) {
        this.router.navigate(['']);
      } else {
        this.disableForm = true;
        this.message = response.message;
      }

      console.log('login onSubmit login:');
      console.log(response);
    });
  }
}
