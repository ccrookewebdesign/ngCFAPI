import { Component, SimpleChanges, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { UserService } from './../services/user.service';

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
    this.loginForm.valueChanges.subscribe(val => {
      this.disableForm = false;
      this.message = '';
    });
  }

  onSubmit() {
    this.message = '';
    this.userService.login(this.loginForm.value).subscribe(response => {
      //console.log(response);
      if (response.success) {
        this.router.navigate(['']);
      } else {
        this.disableForm = true;
        this.message = response.message;
      }
    });
  }
}