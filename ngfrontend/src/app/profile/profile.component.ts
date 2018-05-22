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
      //console.log(this.userid);
    });

    if (this.userid) {
      this.userService.getUser(this.userid).subscribe(data => {
        if (!data.success) {
          if (data.errcode) {
            console.log(data);
          }
          //console.log(data.message);
        } else {
          this.user = JSON.parse(data.data);
          this.populateForm(this.user);
        }
        //console.log('data" ' + JSON.stringify(data));
        console.log('this.user: ' + JSON.stringify(this.user));
      });
    }
  }

  populateForm(data): void {
    console.log(data);
    this.profileForm.patchValue({
      username: data.username,
      firstName: data.firstname,
      lastName: data.lastname,
      email: data.email,
      password: data.password,
      confirmPassword: data.password,
      lastlogin: data.lastlogin
    });
    console.log('populateForm form: ' + JSON.stringify(this.profileForm.value));
  }

  onSubmit(): void {
    this.message = '';
    if (this.profileForm.dirty && this.profileForm.valid) {
      //const theForm = this.profileForm.value;
      if (this.userid) {
        /* console.log(this.userid);
        console.log(this.profileForm.value); */
        this.userService
          .updateUser(this.userid, this.profileForm.value)
          .subscribe(data => {
            if (data.success === false) {
              if (data.errcode) {
                console.log(data);
              }
              console.log(data.message);
            } else {
              console.log(data.message);
              if (this.userid === this.userService.currentUser.userid) {
                const theUser: any = JSON.parse(
                  localStorage.getItem('currentUser')
                );
                //theUser.user.firstName = this.profileForm.value.firstName;
                localStorage.setItem('currentUser', JSON.stringify(theUser));
              }
              this.router.navigate(['']);
            }
          });
      } else {
        this.userService.insertUser(this.profileForm.value).subscribe(data => {
          if (data.success === false) {
            console.log(data.message);
          } else {
            console.log(data.message);
            const theUser: any = JSON.parse(
              localStorage.getItem('currentUser')
            );
            //theUser.user.firstName = this.profileForm.value.firstName;
            localStorage.setItem('currentUser', JSON.stringify(theUser));
            this.router.navigate(['']);
          }
          this.profileForm.reset();
        });
      }
    }
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }
}
