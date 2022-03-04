CBIG Unit Tests
===============

It is very important to regularly test whether our utilities functions and stable projects can work properly. As a result, we have written unit tests for some frequently used utilities functions as well as for some stable projects. Please note that the unit tests **work for CBIG lab only**.

The unit tests are organized into three versions of CBIG unit test sets, namely `light`, `intermediate` and `comprehensive`: 

- **`light`** unit test set - it includes unit tests for important `utilities` and `external_packages` functions. This unit test set will be run when PRs are being submitted or reviewed.

- **`intermediate`** unit test set - it includes the `light` unit test set as well as **some** stable project's unit tests. You can check this file [CBIG_intermediate_unit_test_list](https://github.com/YeoPrivateLab/CBIG_private/blob/develop/unit_tests/CBIG_intermediate_unit_test_list) for the stable projects included in the `intermediate` test set.
    - Anyone who intends to submit a PR to our repo is required to run the `intermediate` unit test on his/her side prior to submitting the PR. 
    - The reviewer of the PR is required to run the `intermediate` unit test set on his side prior to merging the PR.

- **`comprehensive`** unit test set - it includes `light` unit test set as well as **all** stable project's unit tests. This test will be run by a public account on a monthly basis (e.g. once every two months) and also when big/significant changes happens to CBIG group (e.g. recompiling all our c code, changing OS etc).


The unit test scripts are all written in MATLAB classed-based unit test format. They can be easily called by the wrapper function: `CBIG_UnitTests_Wrapper`. After the tests are done, a report indicating whether unit tests are PASSED or FAILED will be saved out in the output directory specified by the user.

Please refer to this [wiki page](https://github.com/YeoPrivateLab/CBIG_private/wiki/CBIG-Unit-Tests) for more information on how to run unit tests, when to run unit tests and also how to write unit tests.
