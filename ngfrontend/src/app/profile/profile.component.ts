import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, ActivatedRouteSnapshot } from '@angular/router';
import {
  FormBuilder,
  FormGroup,
  Validators,
  AbstractControl
} from '@angular/forms';
import { Router } from '@angular/router';

import { Observable } from 'rxjs';
import { map, tap, catchError, switchMap } from 'rxjs/operators';

import { UserService, User } from './../services/user.service';

function passwordConfirm(c: AbstractControl): any {
  if (!c.parent || !c) return;

  const pwd = c.parent.get('password');
  const cpwd = c.parent.get('confirmPassword');

  if (!pwd || !cpwd) return;

  if (pwd.value !== cpwd.value) {
    return { invalid: true };
  }
}

@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.scss']
})
export class ProfileComponent implements OnInit {
  user: User;
  userid: number;
  hide = true;
  pageHeader = 'Register';
  private sub: any;

  message: string;
  disableForm: boolean = false;

  profileForm = this.fb.group({
    username: [
      '',
      [Validators.required, Validators.minLength(5), Validators.maxLength(16)]
    ],
    firstName: ['', Validators.required],
    lastName: ['', [Validators.required]],
    email: ['', [Validators.required, Validators.email]],
    password: [
      '',
      [
        Validators.required,
        Validators.pattern(
          '^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*(),.?":{}|<>]).{8,16}$'
        )
      ]
    ],
    confirmPassword: ['', [Validators.required, passwordConfirm]]
  });

  constructor(
    private route: ActivatedRoute,
    private userService: UserService,
    private fb: FormBuilder,
    private router: Router
  ) {}

  ngOnInit() {
    this.sub = this.route.params.subscribe(params => {
      this.userid = +params['userid'];
    });

    if (this.userid) {
      this.userService.getUser(this.userid).subscribe(data => {
        if (data.success) {
          this.user = JSON.parse(data.data);
          this.pageHeader = this.user.username + ' Details';
          this.populateForm(this.user);
        }
        console.log('profile OnInit getUser');
        console.log(data);
      });
    }
  }

  populateForm(data): void {
    this.profileForm.patchValue({
      username: data.username,
      firstName: data.firstname,
      lastName: data.lastname,
      email: data.email,
      password: data.password,
      confirmPassword: data.password,
      lastlogin: data.lastlogin
    });
  }

  onSubmit(): void {
    this.message = '';
    if (this.profileForm.dirty && this.profileForm.valid) {
      if (this.userid) {
        this.userService
          .updateUser(this.userid, this.profileForm.value)
          .subscribe(data => {
            console.log('profile onSubmit updateUser:');
            console.log(data);

            if (data.success) {
              if (this.userid === this.userService.currentUser.userid) {
                const theUser: any = JSON.parse(
                  localStorage.getItem('currentUser')
                );
                localStorage.setItem('currentUser', JSON.stringify(theUser));
              }
              this.router.navigate(['']);
            } else {
              this.message = data.message;
            }
          });
      } else {
        this.userService.insertUser(this.profileForm.value).subscribe(data => {
          console.log('profile onSubmit insertUser:');
          console.log(data);

          if (data.success) {
            const theUser: any = JSON.parse(
              localStorage.getItem('currentUser')
            );

            localStorage.setItem('currentUser', JSON.stringify(theUser));

            this.router.navigate(['']);
          } else {
            this.message = data.message;
          }
        });
      }
    }
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }
}
